#!/usr/local/bin/konoha

"""
5-1.k
license BSD
author chen_ji <wakamori111 at gmail.com>
"""

using konoha.io.*;

class User
{
    int id;
    int time;
    int take;
    int out;

    User(int id, int time, int take, int out) {
        _id = id;
        _time = time;
        _take = take;
        _out = out;
    }
}

OPEN = 0;
CLOSE = 1;
UP = 2;
DOWN = 3;
WAIT = 4;

class Elevator
{
    int id;
    int floors;
    int movetime;
    int iotime;
    int capacity;
    int currenttime;
    boolean open;
    User[] users;

    Elevator(int id, int floors, int movetime, int iotime, int capacity) {
        _id = id;
        _floors = floors;
        _movetime = movetime;
        _iotime = iotime;
        _capacity = capacity;
        _users = [];
    }

    void declareUsers(String users_str) {
        OUT << "users: " << EOL;
        OUT << users_str << EOL;
        foreach (String user_str in users_str.split("\n")) {
            String[] params = user_str.split(",");
            User user = new User((to int)params[0], (to int)params[1],
                    (to int)params[2], (to int)params[3]);
            users.add(user);
        }
    }

    boolean operate(Tuple<int, int, int[]>[] steps, User[] passengers, int floor,
            int curtime, boolean open) {
        if (users.size == 0) {
            return true;
        }
        //print users;

        if (open) {
            int[] getonuserids = [];
            //foreach (User passenger in passengers) {
            //    if (passenger.out == floor) {
            //        getonuserids.add(passenger.id);
            //    }
            //}
            foreach (User user in users) {
                if (user.time <= curtime) {
                    print user.time, curtime;
                    if (user.take == floor) {
                        getonuserids.add(user.id);
                    }
                } else {
                    break;
                }
            }
            steps.add((CLOSE, getonuserids.size, getonuserids));
            foreach (int userid in getonuserids) {
                //print users, userid;
                foreach (User user in users) {
                    if (user.id == userid) {
                        passengers.add(user);
                    }
                }
            }
            if (operate(steps, passengers, floor, curtime + iotime, !open)) {
                return true;
            }
        }
        int destination;
        if (passengers.size > 0) {
            destination = passengers[0].out;
        } else {
            destination = users[0].take;
        }
        if (floor != destination) {
            int time;
            if (floor < destination) {
                steps.add((UP, destination, new int[0]));
                time = (destination - floor) * movetime;
            } else {
                steps.add((DOWN, destination, new int[0]));
                time = (floor - destination) * movetime;
            }
            //print steps, passengers, destination, open;
            if (operate(steps, passengers, destination,
                        curtime + time, open)) {
                return true;
            }
        } else {
            if (passengers.size > 0) {
                User getoffuser = passengers.pop();
                steps.add((OPEN, 1, [getoffuser.id]));
                for (int i = 0; i < users.size; i++) {
                    if (users[i].id == getoffuser.id) {
                        users.remove(i);
                        break;
                    }
                }
                //print users;
                //print steps, passengers, floor, curtime, open;
                if (operate(steps, passengers, floor, curtime, !open)) {
                    return true;
                }
            } else {
                if (curtime < users[0].time) {
                    int waittime = users[0].time - curtime;
                    steps.add((WAIT, users[0].time - curtime, new int[0]));
                    if (operate(steps, passengers, floor,
                                curtime + waittime, open)) {
                        return true;
                    }
                } else {
                    steps.add((OPEN, 0, new int[0]));
                    if (operate(steps, passengers, floor, curtime, !open)) {
                        return true;
                    }
                    //    steps.add((CLOSE, 1, [users[0].id]));
                    //    passengers.add(users[0]);
                    //    operate(steps, passengers, floor, curtime + iotime, !open);
                }
            }
        }
        return false;
    }

    String toStringStep(int time, int floor, String door, int[] passengers) {
        String step_str = "";
        step_str += (to String)id + "," + (to String)time + ",";
        step_str += (to String)floor + "," + door + ",";
        for (int i = 0; i < 5; i++) {
            if (i < passengers.size) {
                step_str += (to String)passengers[i];
            } else {
                step_str += "0";
            }
            if (i < 4) {
                step_str += ",";
            }
        }
        return step_str;
    }

    String outputSteps(Tuple<int, int, int[]>[] steps) {
        String steps_str = "";
        int time = 0;
        int floor = 1;
        String door = "E";
        int[] passengers = [];
        //for (int index = 0; index < steps.size; index++) {
        //    Tuple<int, int, int[]> step = steps[index];
        foreach (Tuple<int, int, int[]> step in steps) {
            switch (step[0]) {
            case OPEN:
                door = "B";
                steps_str += toStringStep(time, floor, door, step[2]) + "\n";
                if (step[1] > 0) {
                    foreach (int i in step[2]) {
                        for (int j = 0; j < passengers.size; j++) {
                            if (passengers[j] == i) {
                                passengers.remove(j);
                                continue;
                            }
                        }
                    }
                }
                break;
            case CLOSE:
                time += iotime;
                door = "E";
                steps_str += toStringStep(time, floor, door, step[2]) + "\n";
                if (step[1] > 0) {
                    foreach (int i in step[2]) {
                        passengers.add(i);
                    }
                }
                break;
            case UP:
                time += (step[1] - floor) * movetime;
                floor = step[1];
                break;
            case DOWN:
                time += (floor - step[1]) * movetime;
                floor = step[1];
                break;
            case WAIT:
                time += step[1];
                break;
            }
        }
        return steps_str;
    }

    String work() {
        Tuple<int, int, int[]>[] steps = [];
        User[] passengers = [];
        print operate(steps, passengers, 1, 0, false);
        for (int i = 0; i < steps.size; i++) {
            print i, steps[i];
        }
        //print steps;
        OUT <<  outputSteps(steps) << EOL;
        return "";
    }
}

void main(String[] args)
{
    if (args.size != 1) {
        ERR << "Usage: konoha " + $script.name + " input.csv" << EOL;
        exit(1);
    }
    InputStream input_csv = new InputStream(args[0]);
    elevator = new Elevator(1, 10, 2, 5, 1);
    elevator.declareUsers(input_csv.read().decode().trim());
    OUT << elevator.work() << EOL;
}
