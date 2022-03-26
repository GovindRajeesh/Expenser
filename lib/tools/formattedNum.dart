String formattedNum(n){
  var newNum=n;
  if(newNum.toString().contains(".") && newNum.toString().split(".")[1]=="0"){
      newNum=num.parse(newNum.toString().split(".")[0]);
    }
  if(n>=1000){
    newNum=(n/1000);
    return newNum.toString()+"k";
  }else{return n.toString();}
}