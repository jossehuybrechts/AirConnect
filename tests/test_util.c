#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>
#include "cross_util.h"

// Stub functions that might be needed by cross_util.c linking
void log_print() {}
int util_loglevel = 0;

void test_url_decode() {
    char url1[] = "hello%20world";
    char* decoded = url_decode(url1);
    assert(strcmp(decoded, "hello world") == 0);
    free(decoded);

    char url2[] = "some%2Btext";
    decoded = url_decode(url2);
    assert(strcmp(decoded, "some+text") == 0);
    free(decoded);
}

void test_base64() {
    const char* text = "base64test";
    char* encoded = NULL;
    int enc_len = base64_encode(text, strlen(text), &encoded);
    assert(encoded != NULL);
    assert(enc_len > 0);

    char decoded[128] = {0};
    int dec_len = base64_decode(encoded, decoded);
    assert(dec_len == strlen(text));
    assert(strcmp(decoded, text) == 0);

    free(encoded);
}

int main() {
    printf("Running comprehensive C utilities tests...\n");

    // Test strltrim
    char str1[] = "   hello";
    assert(strcmp(strltrim(str1), "hello") == 0);

    // Test strrtrim
    char str2[] = "hello   ";
    assert(strcmp(strrtrim(str2), "hello") == 0);

    // Test strtrim
    char str3[] = "  hello  ";
    assert(strcmp(strtrim(str3), "hello") == 0);

    // Test strremovechar
    char str4[] = "hello world";
    strremovechar(str4, 'l');
    assert(strcmp(str4, "heo word") == 0);

    test_url_decode();
    test_base64();

    printf("All comprehensive C utilities tests passed!\n");
    return 0;
}
