/**
 * 
 */
 
 function inputNum(input){
	input.value = input.value.replace(/[^0-9.]/g, '').replace(/(\..*)\./g, '$1');
}