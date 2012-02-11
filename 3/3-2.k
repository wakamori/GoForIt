#!/usr/local/bin/konoha

"""
3-2.k
license BSD
author chen_ji <wakamori111 at gmail.com>
"""

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

int[] qs_table;

// quick search
int qs_search(String buff, int column, int skip_count, String pattern) {
    int i = column;
    int n = 0;
    while (i < buff.size) {
        n++;
        i += skip_count;
    }
    int m = pattern.size;
    int i = 0;
    while (i < n - m) {
        int j = 0;
        while (j < m) {
            if (buff[column + (i + j) * skip_count] != pattern[j]) {
                break;
            }
            j++;
        }
        if (j == m) {
            // found
            return i;
        } else {
            i += qs_table[(to int)buff[column + (i + m) * skip_count].encode()[0]];
        }
    }
    int j = column + i * skip_count;
    String last = "";
    while (j < buff.size) {
        last += buff[j];
        j += skip_count;
    }
    if (last == pattern) {
        return i;
    }
    return -1;
}

// find pattern
boolean find(String buff, String word, int skip_count) {
    for (int column = 0; column < skip_count; column++) {
        int r = qs_search(buff, column, skip_count, word);
        if (r >= 0) {
            OUT << skip_count << "," << (r * skip_count + column + 1) << EOL;
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
    qs_table = make_qs_table(keyword, keyword.size);
    OUT << "keyword: " << keyword << EOL;
    OUT << "search string: ";
    OUT.flush();
    String rand_str = IN.read().decode();
    int l = rand_str.size;
    OUT << EOL << "order: ";
    OUT.flush();
    for (int i = 1; i <= l; i++) {
        if (find(rand_str, keyword, i)) {
            break;
        }
    }
    String rkeyword = "";
    for (int i = keyword.size - 1; i >= 0; i--) {
        rkeyword += keyword[i];
    }
    qs_table = make_qs_table(rkeyword, rkeyword.size);
    OUT << "reverse order: ";
    OUT.flush();
    for (int i = 1; i <= l; i++) {
        if (find(rand_str, rkeyword, i)) {
            break;
        }
    }
}
