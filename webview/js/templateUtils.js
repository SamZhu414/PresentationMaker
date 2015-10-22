window.onload=function(){
    var textDomList=document.getElementsByClassName("text_element");
    for(var i=0;i<textDomList.length;i++){
        textDomList[i].index=i;
        textDomList[i].addEventListener("click",function(){
            console.log("text_element:",new String(this.innerHTML).trim(), this.index);
            clickedText(this.innerHTML, this.index);
        })
    }

    var imgDomList=document.getElementsByClassName("img_element");
    for(var i=0;i<imgDomList.length;i++){
        imgDomList[i].index=i;
        imgDomList[i].addEventListener("click",function(){
            console.log("img_element:", this.index);
            clickedImage(this.index);
        })
    }
}