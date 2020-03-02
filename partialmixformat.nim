import os, osproc, tempfile, typetraits, strutils
import nre except toSeq

type
  FilePosition = tuple
    start: int
    size: int

type
  Diff = tuple
    prev: FilePosition
    new: FilePosition

proc amended_lines(diff_file :string): seq[Diff] =
  let diff_content  = readFile(diff_file)
  var res: seq[Diff] = @[]
  var diff_sequence = diff_content.split(re"@@")
  echo diff_sequence
  diff_sequence.delete(0)
  for diff_block in diff_sequence:
    echo diff_block
    let captures = diff_block.find(re"-([0-9]+),?([0-9]*) \+([0-9]+),?([0-9]*)").get.captures()
    let prev_size = if captures[1] == "" : 0
                    else: captures[1].parseInt()
    let next_size = if captures[3] == "" : 0
                else: captures[3].parseInt()
    res.add(((captures[0].parseInt(),prev_size),(captures[2].parseInt(),next_size)))
  return res


# proc match_diff()

proc main() =
  if paramCount() != 1:
    quit("synopsis: " & getAppFilename() & " filename keyfield valuefield")
  let
    filename = paramStr(1)

  var (_ , name_tempfile_original) = mkstemp()
  echo name_tempfile_original

  var (_ , name_tempfile_fmt) = mkstemp()
  echo name_tempfile_fmt

  var (_ , diff_with_head) = mkstemp()
  echo diff_with_head

  var (_ , diff_with_fmt) = mkstemp()
  echo diff_with_fmt

  copyFile(filename,name_tempfile_original)
  copyFile(filename,name_tempfile_fmt)

  let errC_mix_format = execCmd("mix format " & name_tempfile_fmt)

  let errC_git_diff = execCmd("git diff -U0 HEAD " & filename & " > " & diff_with_head )
  let errC_diff_formated = execCmd("diff -U 0 " & name_tempfile_original & " " & name_tempfile_fmt & " > " & diff_with_fmt )

  let indexes_diff_with_head = amended_lines(diff_with_head)
  echo indexes_diff_with_head

  # let indexes_diff_fmt = amended_lines(diff_with_fmt)
  # echo indexes_diff_fmt

main()
