#!/bin/bash

print_func_info () {
	func_name=$1
	
	num_occurrences=$(grep -ir "$func_name(.*)" *\.gd | wc -l)
	echo "# of occurrences of $func_name: $num_occurrences"
	
	if [ $num_occurrences -gt 0 ]
	then
		echo "**files containing $func_name:"
		grep -ilr "$func_name(.*)" *\.gd
		
		echo "**lines are:"
		grep -inrH "$func_name(.*)" *\.gd
	fi
	
	echo
}

echo "looking for outdated functions: get_type(), get_pos(), get_global_pos(),"
echo "get_rot(), get_global_rot(), get_rotd(), get_global_rotd()"
echo "set_pos(), set_global_pos(), set_rot(), set_global_rot(), set_rotd(), set_global_rotd()"
echo ""

func_names=(get_type get_pos get_global_pos get_rot get_global_rot get_rotd get_global_rotd set_pos set_global_pos set_rot set_global_rot set_rotd set_global_rotd)

#echo function names are ${func_names[*]}
#echo ""

for name in ${func_names[*]} ; do
	print_func_info $name
done





