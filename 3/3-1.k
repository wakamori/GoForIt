#!/usr/local/bin/konoha

using konoha.io.*;
// table size (ascii)
CSIZE = 256

// make displacement table
int[] make_qs_table(String pattern, int size) {
	int[] qs_table = new int[CSIZE];
	qs_table.setAll(size + 1);
	for (int i = 0; i < size; i++) {
		qs_table[(to int)pattern[i].encode()[0]] = size - i;
	}
	return qs_table;
}

// quick search
int qs_search(String buff, String pattern) {
	int n = buff.size;
	int m = pattern.size;
	int[] qs_table = make_qs_table(pattern, m);
	int i = 0;
	while (i < n - m) {
		int j = 0;
		while (j < m) {
			if (buff[i + j] != pattern[j]) {
				break;
			}
			j++;
		}
		if (j == m) {
			// found
			return i;
		} else {
			i += qs_table[(to int)buff[i + m].encode()[0]];
		}
	}
	if (i <= n && buff.substring(i) == pattern) {
		return i;
	}
	return -1;
}

// find pattern
boolean find(String buff, String word, int skip_count) {
	int l = buff.size;
	for (int count = 0; count < skip_count; count++) {
		String search_buff = "";
		int cur = count;
		while (cur < l) {
			search_buff += buff[cur];
			cur += skip_count;
		}
		int r = qs_search(search_buff, word);
		if (r >= 0) {
			OUT << skip_count << "," << (r * skip_count + count + 1) << EOL;
			return true;
		}
	}
	return false;
}

void main(String[] args)
{
	if (args.size != 1) {
		OUT << "Usage: " + $script.name + " keyword" << EOL;
		System.exit(1);
	}
	String keyword = args[0];
	OUT << "keyword: " << keyword << EOL;
	OUT << "search string: ";
	//String rand_str = "";
	//Bytes buf = new byte[4096];
	//while (IN.read(buf, buf.size - 1).size > 0) {
	//	rand_str += buf.decode();
	//}
	String rand_str = IN.read().decode();
	int l = rand_str.size;
	OUT << EOL << "order: ";
	for (int i = 1; i <= l; i++) {
		if (find(rand_str, keyword, i)) {
			break;
		}
	}
	String rkeyword = "";
	for (int i = keyword.size - 1; i >= 0; i--) {
		rkeyword += keyword[i];
	}
	OUT << "reverse order: ";
	for (int i = 1; i <= l; i++) {
		if (find(rand_str, rkeyword, i)) {
			break;
		}
	}
	OUT << EOL;
}
