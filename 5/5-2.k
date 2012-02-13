#!/usr/local/bin/konoha

"""
5-2.k
license BSD
author chen_ji <wakamori111 at gmail.com>
"""

using konoha.io.*;
using konoha.math.*;

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

class Movement
{
    int id;
    int time;
    int floor;
    boolean open;
    int[] passengers;

    Movement(int id, int time, int floor, boolean open, int[] passengers) {
        _id = id;
        _time = time;
        _floor = floor;
        _open = open;
        _passengers = passengers;
    }
}

class Checker
{
    String input;
    String output;
    User[] users;
    Movement[] movements;

    Checker(String input, String output) {
        _input = input;
        _output = output;
        users = [];
        foreach (String user_str in input.split("\n")) {
            String[] params = user_str.split(",");
            User user = new User((to int)params[0], (to int)params[1],
                    (to int)params[2], (to int)params[3]);
            _users.add(user);
        }
        movements = [];
        foreach (String step_str in output.split("\n")) {
            String[] params = step_str.split(",");
            Movement movement = new Movement((to int)params[0],
                    (to int)params[1], (to int)params[2], params[3] == "B",
                    [(to int)params[4], (to int)params[5], (to int)params[6],
                    (to int)params[7], (to int)params[8]]);
            movements.add(movement);
        }
    }

    boolean checkUserisCorrect(User user) {
        boolean found = false;
        foreach (Movement move in movements) {
            if (!found) {
                if (user.id in? move.passengers) {
                    if (move.time < user.time) {
                        print user, move;
                        return false;
                    }
                    if (move.floor != user.take) {
                        print user, move;
                        return false;
                    }
                    found = true;
                }
            } else {
                if (user.id in? move.passengers) {
                    if (move.floor != user.out) {
                        print user, move;
                        return false;
                    }
                    return true;
                }
            }
        }
        print user;
        return false;
    }

    boolean checkDeclaration() {
        foreach (User user in users) {
            if (!checkUserisCorrect(user)) {
                print user;
                return false;
            }
        }
        return true;
    }

    boolean checkOperation() {
        boolean open = false;
        int prevfloor = 1;
        int prevtime = 0;
        foreach (Movement move in movements) {
            if (move.open == open) {
                print move;
                return false;
            }
            if (move.open) {
                if (move.floor != prevfloor && (move.time - prevtime) /
                        Math.abs(move.floor - prevfloor) < 2) {
                    print move;
                    return false;
                }
            } else {
                if (move.time - prevtime < 5) {
                    print move;
                    return false;
                }
            }
            open = move.open;
            prevfloor = move.floor;
            prevtime = move.time;
        }
        return true;
    }

    int getUserDeclarationTime(User user) {
        boolean found = false;
        int starttime = 0;
        foreach (Movement move in movements) {
            if (!found) {
                if (user.id in? move.passengers) {
                    starttime = user.time;
                    found = true;
                }
            } else {
                if (user.id in? move.passengers) {
                    return move.time - starttime;
                }
            }
        }
        return -1;
    }

    int getTotalTime() {
        int totaltime = 0;
        foreach (User user in users) {
            totaltime += getUserDeclarationTime(user);
        }
        return totaltime;
    }
}

void main(String[] args)
{
    if (args.size != 2) {
        ERR << "Usage: konoha " + $script.name + " input.csv output.csv" << EOL;
        exit(1);
    }
    InputStream input_csv = new InputStream(args[0]);
    InputStream output_csv = new InputStream(args[1]);
    Checker checker = new Checker(input_csv.read().decode().trim(),
            output_csv.read().decode().trim());
    if (checker.checkDeclaration()) {
        OUT << "All declarations are correctly satisfied." << EOL;
    } else {
        OUT << "Not satisfied declarations exist." << EOL;
    }
    if (checker.checkOperation()) {
        OUT << "All operations are correct." << EOL;
    } else {
        OUT << "Incorrect operations exist." << EOL;
    }
    OUT << "total declaration time: " << checker.getTotalTime() << EOL;
}
