#!/bin/sh

test_description='checkout --no-overlay <tree-ish> -- <pathspec>'

. ./test-lib.sh

test_expect_success 'setup' '
	git commit --allow-empty -m "initial"
'

test_expect_success 'checkout --no-overlay deletes files not in <tree-ish>' '
	>file &&
	mkdir dir &&
	>dir/file1 &&
	git add file dir/file1 &&
	git checkout --no-overlay HEAD -- file &&
	test_path_is_missing file &&
	test_path_is_file dir/file1
'

test_expect_success 'checkout --no-overlay removing last file from directory' '
	git checkout --no-overlay HEAD -- dir/file1 &&
	test_path_is_missing dir
'

test_expect_success 'checkout -p --overlay is disallowed' '
	test_must_fail git checkout -p --overlay HEAD 2>actual &&
	test_i18ngrep "fatal: -p and --overlay are mutually exclusive" actual
'

test_expect_success '--no-overlay --theirs with D/F conflict deletes file' '
	test_commit file1 file1 &&
	test_commit file2 file2 &&
	git rm --cached file1 &&
	echo 1234 >file1 &&
	F1=$(git rev-parse HEAD:file1) &&
	F2=$(git rev-parse HEAD:file2) &&
	{
		echo "100644 $F1 1	file1" &&
		echo "100644 $F2 2	file1"
	} | git update-index --index-info &&
	test_path_is_file file1 &&
	git checkout --theirs --no-overlay -- file1 &&
	test_path_is_missing file1
'

test_expect_success 'checkout with checkout.overlayMode=false deletes files not in <tree-ish>' '
	>file &&
	mkdir dir &&
	>dir/file1 &&
	git add file dir/file1 &&
	git -c checkout.overlayMode=false checkout HEAD -- file &&
	test_path_is_missing file &&
	test_path_is_file dir/file1
'

test_done
