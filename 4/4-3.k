#!/usr/local/bin/konoha

"""
4-3.k
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
	String rawpitch;
	String rawlength;
	String accidental;

	Note(String pitch, String length, String accidental) {
		if (pitch == "") {
			_rest = true;
			_pitch = 0;
		} else {
			_rest = false;
			_pitch = (to int)pitch;
		}
		_rawpitch = pitch;
		if (length.endsWith(".")) {
			_dotted = true;
			_length = (to int)length.substring(0, length.size - 1);
		} else {
			_dotted = false;
			_length = (to int)length;
		}
		_rawlength = length;
		_accidental = accidental;
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

	String toString() {
		return rawpitch + ":" + rawlength + ":" + accidental;
	}
}

// score class
class Score
{
	InputStream sfile;
	Note[] notes;

	Score(Path scorefile) {
		if ((to String)scorefile != "") {
			_sfile = new InputStream(scorefile);
			createScore();
		}
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

	String toString() {
		String score_str = "";
		foreach (Note note in notes) {
			score_str += note.toString();
			score_str += ",";
		}
		if (score_str != "") {
			score_str = score_str.substring(0, score_str.size - 1);
		}
		return score_str;
	}
}

class Composer
{
	int start_pitch;
	int end_pitch;
	int measure_min;
	int measure_max;
	int feature_val;

	Composer(int start_pitch, int end_pitch, int measure_min,
			int measure_max, int feature_val) {
		_start_pitch = start_pitch;
		Note end_note = new Note((to String)end_pitch, "1", "");
		_end_pitch = end_note.pitch;
		_measure_min = 64 * measure_min;
		_measure_max = 64 * measure_max;
		_feature_val = feature_val;

	}

	Note[] generateRandomNotes() {
		Note[] notes = [];
		Tuple<int, String>[] rand_pitches = [];
		for (int i = -6; i < 8; i++) {
			rand_pitches.add((i, ""));
			if (i == -5 || i == -4 || i == -2 || i == -1 || i == 0) {
				rand_pitches.add((i, FLAT));
			} else if (i == 1 || i == 2 || i == 4 || i == 5 || i == 6) {
				rand_pitches.add((i, SHARP));
			}
		}
		rand_pitches.shuffle();
		foreach (Tuple<int, String> pitch in rand_pitches) {
			String pitch_str;
			boolean isRest;
			if (pitch[0] == 7) {
				pitch_str = "";
				isRest = true;
			} else {
				pitch_str = (to String)pitch[0];
				isRest = false;
			}
			Note note = new Note(pitch_str, generateLength(isRest),
					pitch[1]);
			notes.add(note);
		}
		return notes;
	}

	boolean setNote(Note[] notes, int total_val, int total_length) {
		//ERR << "total: " << total_length << ", feat: " + total_val << EOL;
		if (total_val > feature_val || total_length > measure_max) {
			return false;
		}
		if (total_length >= measure_min) {
			if (notes[notes.size - 1].pitch == end_pitch) {
				if (total_val == feature_val) {
					return true;
				}
			} else {
				return false;
			}
		}

		Note[] rand_notes = generateRandomNotes();
		foreach (Note note in rand_notes) {
			Note pre_note = notes[notes.size - 1];
			int diff = 0;
			if (note.rest) {
				if (pre_note.rest) {
					continue;
				}
				diff = 0;
			} else {
				if (pre_note.rest) {
					pre_note = notes[notes.size - 2];
				}
				diff = Math.abs(note.pitch - pre_note.pitch);
			}
			notes.add(note);
			if (setNote(notes, total_val + diff, total_length + note.length)) {
				return true;
			}
			notes.pop();
		}
		return false;
	}

	Score generate() {
		Note start_note = new Note((to String)start_pitch, generateLength(), "");
		Note[] notes = [start_note];
		setNote(notes, 0, start_note.length);
		Score score = new Score();
		score.notes = notes;
		return score;
	}

	String generateLength(boolean isRest) {
		int count = Int.random(6);
		int length = 1;
		for (int i = 0; i < count; i++) {
			length *= 2;
		}
		if (isRest) {
			return (to String)length;
		}
		return (to String)length + ((Int.random(2) == 0) ? "." : "");
	}
}

void main(String[] args)
{
	Composer composer = new Composer(-2, -2, 3, 4, 51);
	String str = composer.generate().toString();
	OUT << str << EOL;
}
