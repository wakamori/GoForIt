#!/usr/local/bin/konoha

"""
4-1and2.k
license BSD
author chen_ji <wakamori111 at gmail.com>
"""

using konoha.io.*;
using konoha.math.*;

// accidental string
SHARP  = "s";
DSHARP = "x";
FLAT   = "b";
DFLAT  = "d";

// note class
class Note
{
    boolean rest;
    boolean dotted;
    int pitch;
    int length;
    String accidental;

    Note(String pitch, String length, String accidental) {
        if (pitch == "") {
            _rest = true;
            _pitch = 0;
        } else {
            _rest = false;
            _pitch = (to int)pitch;
        }
        if (length.endsWith(".")) {
            _dotted = true;
            _length = (to int)length.substring(0, length.size - 1);
        } else {
            _dotted = false;
            _length = (to int)length;
        }
        if (accidental == "") {
            _accidental = "";
        } else {
            _accidental = accidental;
        }
        considerAccidental();
        considerLength();
    }

    void considerAccidental() {
        int diff = 0;
        switch (pitch % 7) {
            case 0: case 1:
                diff = 0;
                break;
            case 2: case -1:
                diff = 1;
                break;
            case 3: case 4: case -2:
                diff = 2;
                break;
            case 5: case -3: case -4:
                diff = 3;
                break;
            case 6: case -5:
                diff = 4;
                break;
            case -6:
                diff = 5;
                break;
        }
        if (pitch >= 0) {
            _pitch += (pitch / 7) * 5 + diff;
        } else {
            _pitch -= ((-pitch / 7) * 5 + diff);
        }
        switch (accidental) {
            case SHARP:
                _pitch += 1;
                break;
            case DSHARP:
                _pitch += 2;
                break;
            case FLAT:
                _pitch -= 1;
                break;
            case DFLAT:
                _pitch -= 2;
                break;
            default:
                break;
        }
    }

    void considerLength() {
        _length = 64 / length;
        if (dotted) {
            _length *= 1.5;
        }
    }
}

// score class
class Score
{
    InputStream sfile;
    Note[] notes;

    Score(Path scorefile) {
        _sfile = new InputStream(scorefile);
        createScore();
    }

    void createScore() {
        String input = sfile.read().decode().trim();
        String[] notes_str = input.split(",");
        notes = [];
        foreach (String note_str in notes_str) {
            String[] attr = note_str.split(":");
            notes.add(new Note(attr[0], attr[1], attr[2]));
        }
    }
}

// extractor class
class Extractor
{
    Score score;

    Extractor(Score score) {
        _score = score;
    }

    int extractFeature() {
        int feature_val = 0;
        Note pre_note = null;
        foreach (Note note in score.notes) {
            if (note.rest) {
                continue;
            } else if (pre_note != null) {
                feature_val += Math.abs(note.pitch - pre_note.pitch);
            }
            pre_note = note;
        }
        return feature_val;
    }
}

void main(String[] args)
{
    if (args.size != 1) {
        ERR << "Usage: konoha " + $script.name + " input.score" << EOL;
        exit(1);
    }
    Score score = new Score(args[0]);
    Extractor extractor = new Extractor(score);
    OUT << "feature value: " << extractor.extractFeature() << EOL;
}
