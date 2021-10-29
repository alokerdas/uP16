#!/usr/bin/tcsh -f

set script_dir = "$PWD"
set asmsToCheck = "$*"
if ($#argv < 1) then
  echo "Usage ./automaion.tcsh *"
  echo "Usage ./automaion_v.tcsh add_store"
  echo "Use * to run similar directories. For example add_* will run all the directories starting with add"
  exit (1)
endif

set path=($HOME/projects/install/iverilog/bin $path)
set local_cmd = "./runme"
set default_cmd = "../a.out"
set asmlog = "asm.log"
set asmgold = "$asmlog.gold"
set fullog = "$script_dir/detailed.log"
set faillog = "$script_dir/fail.log"
set paslog = "$script_dir/pas.log"
rm -f $fullog $faillog $paslog

foreach asm ($asmsToCheck)
  if (-d $asm ) then
    cd $asm
    rm -f $asmlog
    echo "Running $asm..."
    echo "Running $asm..." >>& $fullog
    if (-e $local_cmd) then
      $local_cmd >& $asmlog
      cat $asmlog >>& $fullog
    else
      $default_cmd >& $asmlog
      cat $asmlog >>& $fullog
    endif
    if (-e $asmlog) then
        if (-z $asmlog) then
          echo "$asm did not run properly"
          echo "$asm did not run properly" >> $fullog
        else
          # iverilog ran correctly
          if (-e $asmgold) then
            diff $asmgold $asmlog >>& $fullog
            if ($status) then
              echo $asm FAIL
              echo $asm FAIL >> $faillog
            else
              echo $asm PASS
              echo $asm PASS >> $paslog
              rm -f $asmlog
            endif
          else
            # copy lint log to lint golden log
            mv $asmlog $asmgold
          endif
        endif
    else
      echo "$asm did not run properly"
      echo "$asm did not run properly" >> $fullog
      echo "$asm did not run properly" >> $faillog
    endif
    cd ..
  else
    echo "No directory, Skipping the $asm"
    echo "No directory, Skipping the $asm" >> $fullog
    echo "No directory, Skipping the $asm" >> $faillog
  endif
end
