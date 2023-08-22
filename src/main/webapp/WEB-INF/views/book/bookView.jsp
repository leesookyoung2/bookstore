<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ include file="../include/header.jsp" %>     
<link rel="stylesheet" href="${pageContext.request.contextPath}/star-rating/css/star-rating.min.css" media="all" type="text/css"/>
<link rel="stylesheet" href="${pageContext.request.contextPath}/star-rating/themes/krajee-svg/theme.min.css" media="all" type="text/css"/>
<script src="${pageContext.request.contextPath}/star-rating/js/star-rating.min.js" type="text/javascript" ></script>
<script src="${pageContext.request.contextPath}/star-rating/themes/krajee-svg/theme.min.js" type="text/javascript"></script>
<style>
	.btn_rud{
		display:flex;
		gap:5px;
		justify-content: center;
	}
	th{
		width:100px;	
	}
	td{
		text-align: left;
	}
</style>
<main>
<h2>도서 상세</h2>
<form action="book?cmd=view" method="post"  enctype="multipart/form-data" id="uploadForm" name="uploadForm" >
	<input type="hidden" value="${vo.bno}" name="bno" id="bno">
	<table class="table table-sm table-bordered">
		<tr>
			<th>도서제목</th>
			<td class="disp" >${vo.title}</td>
			<td class="edit" style="display:none;">
				<input type="text" size="120" maxlength="50" name="title" id="title" 
			    value="${vo.title}" placeholder="도서명입력" required>
			</td>
		</tr>
        <tr>
			<th>저자</th>
			<td  class="disp" >${vo.writer}</td>
			<td class="edit" style="display:none;">
				<input type="text" size="120"  maxlength="30" name="writer" 
				value="${vo.writer}" id="writer" placeholder="저자명입력">
			</td>
		</tr>
        <tr>
			<th>출판사</th>
			<td class="disp" >${vo.publisher}</td>
			<td class="edit" style="display:none;">
			 <input type="text" size="120"  maxlength="30" name="publisher" 
			 value="${vo.publisher}" id="publisher" placeholder="출판사명입력">
			</td>
		</tr>
        <tr>
			<th>가격</th>
			<td class="disp" ><fmt:formatNumber value="${vo.price}" type="currency" currencySymbol="\\"> </fmt:formatNumber></td>
			<td class="edit" style="display:none;">
				<input type="text" size="120"  maxlength="7" name="price" id="price" 
				  value="${vo.price}" onkeydown="inputNum(this)" placeholder="가격입력" required>
			</td>
		</tr>
        <tr>
			<th>도서내용</th>
			<td class="disp" >
			<% 
				BookVO vo=(BookVO)request.getAttribute("vo");
				if(vo!=null){
					String content=vo.getContent();
					if(content!=null)
						out.write(content.replaceAll("\r\n", "<br>"));
				}
			%>
			</td>
			<td class="edit" style="display:none;">
				<textarea name="content" id="content" cols="119" rows="10" 
					maxlength="1000">${vo.content}</textarea>
			</td>
		</tr>
		<tr>
			<th>도서 이미지</th>
			<td class="disp" >
				<c:if test="${vo.saveFilename!=null}">
					<img src="book?cmd=imgDown&upload=${vo.savePath}&saveFname=${vo.saveFilename}&originFname=${vo.srcFilename}" alt="" height="300px">
				</c:if>				
			</td>
			<td class="edit" style="display:none;">
					<div>
						<c:if test="${vo.saveFilename!=null}">
							기존 파일명 : ${vo.srcFilename}
						</c:if>
					</div><br>
					<div class="form-group row">
						<label for="file" class="col-sm-2 col-form-label">파일첨부</label>
						<div class="col-sm-10">
							<input type="file" name="file" id="file">
							<small class="text-muted">(파일크기 : 2MB / 이미지 파일만 가능)</small>
							<small id="file" class="text-info"></small>
						</div>
					</div>						
				</td>
		</tr>
		<tr>
			<th>평균 별점</th>
			<td> 
				<input id="avgscore" name="avgscore" value="${avgScore}" class="rating rating-loading" data-size="sm" readonly="readonly"> &nbsp;&nbsp;&nbsp; 평가자 인원수 : <span id="span-cnt">${cnt}</span> 
			</td>
		</tr>
	</table>
	<!-- 별점 저장 시작 -->
	<c:if test="${sessionScope.mvo!=null}">
	<div>
	<label for="input-1" class="control-label">별점 저장하기</label>	
<table>
	<tr>
		<td width="300px">
			<input id="score" name="score" class="rating rating-loading" data-size="sm" data-min="0" data-max="5" data-step="0.5" required="required">
		</td>
		<td>
			평가글 남기기 : <input type="text" maxlength="100" id="cmt" name="cmt" size="50" required="required">
			<button type="button" onclick="saveStar()">저장하기</button>		
			</td>
	</tr>
</table>
	</div>
	</c:if>
	<!-- 별점 저장 끝 -->
	<br>
	<div class="btn_rud">
		<button type="button" id="btnList" onclick="location.href='book?cmd=list&page=${page}&searchword=${searchword}&searchtype=${searchtype}'" class="btn btn-success" >도서목록</button>
		<c:if test="${sessionScope.mvo.grade=='a'}">
			<button type="button" id="btnEdit" onclick="bookEdit()" class="btn btn-warning" >도서수정</button>
	 		<button type="button" id="btnDelete" onclick="bookDelete()" class="btn btn-danger" >도서삭제</button> 
	 		<button type="submit" id="btnSave" class="btn btn-primary" style="display:none;">도서저장</button> 
	 		<button type="reset" id="btnCancle" onclick="bookCancle()" class="btn btn-info" style="display:none;">수정취소</button>
 		</c:if> 
    </div>
	</form>
	<br>
	<input type="hidden" name="page" id="page" value="0">
	<table id="tbl_star">
		
	</table>
	<button type="button" id="btn_next" style="display:none" onclick="getStar()">더보기</button>
</main>
<script type="text/javascript">
/*=============================================
* ready fun 호출
*=============================================*/
$(document).ready(function(){
	getStar();
});

/*=============================================
* 스타레이팅 초기화
*=============================================*/
function newStar(){
	// loding 중인 별점을 보여주는 작업
	let ratingStar=$(".rating-loading");
	if(ratingStar.length){//별점보여주기가 1개 이상 있으면
		ratingStar.removeClass("rating-loading").addClass("rating-loading").rating();
	}
	
	//재생성시 크기가 중간 사이즈 고정되는 버그로 작은사이즈로 일괄 변경 추가
	$(".rating-container").removeClass("rating-md rating-sm");
	$(".rating-container").addClass("rating-sm");
}
/*=============================================
*	댓글 가져오기 수행 ajax : doAjax(url, param, callback)
*	- 보내는 데이터 : bno, page
*	- 받아오는 데이터 : json(더보기 버튼 활성화 여부,출력할 데이터(배열))	
*=============================================*/
function getStar(){
		let url="book?cmd=getstar";
		let param={"bno":$("#bno").val(),
				   "page":$("#page").val()*1+1
				   };
		//증가한 페이지를 적용
		$("#page").val($("#page").val()*1+1);
		console.log(param);
		doAjax(url, param, getStarAfter);
}
/*=============================================
*	댓글 가져오기 수행 후 해야 할 일
*	- 받아오는 데이터 : json를 table 태그 내에 출력	
*=============================================*/
function getStarAfter(data){
	console.log("getStarAfter");	
	if(data=="err"){
 		// 표시할 자료 없음
 	}else{
	 		console.log(data);	 
	 		//data 배열에 있는 값을 tbl_star 에 html 태그로 조립해서 출력 
	 		let starList=data.arr;
	 		console.log(starList);
	 		let html="";
	 		for(let vo of starList){//js foreach
	 			html+='<tr>';
	 			html+='<td>';
	 			html+='<input id="score" name="score" value='+vo.score+' class="rating rating-loading" data-size="sm" readonly="readonly">';
	 			html+='</td>';
	 			html+='<td>'+vo.id+' 님 : '+vo.cmt+'</td>';
	 			html+='</tr>';	 			
	 		}//for
	 		$("#tbl_star").append(html);
	 		//let next=data.next;//true, false
	 		//console.log(next);
	 		if(data.next){//더보기 버튼을 보여주기
	 			$("#btn_next").css("display","block");
	 		}else $("#btn_next").css("display","none");
	 		
	 		newStar();
 	}
}

/*===================================================
Ajax 별점과 commemt  저장
common.js doAjaxHtml(url, param, callback) 호출
===================================================*/
function saveStar(){
	let cmt=$("#cmt").val().trim();
	if(cmt==""){
		alert("평가글을 입력하세요");
		$("#cmt").focus();
	}
	let url="book?cmd=savestar";//서블릿 매핑 주소
	let param={"id":"${sessionScope.mvo.id}",
			   "bno":document.getElementById("bno").value,
			   "score":$("#score").val(),
			   "cmt":cmt
			   };
	console.log(param);
	doAjaxHtml(url, param, saveStarAfter);
}
/*===================================================
Ajax 별점과 commemt  저장 완료 후 수행할 함수
callback에 의해서 호출
===================================================*/
function saveStarAfter(data){
	console.log("saveStarAfter");
	console.log(data);
	let retData=JSON.parse(data);
	// 가져온 데이터(수정된 평균값,개수) 설정
	//$("#avgscore").val(retData.avgScore);
	$("#avgscore").rating("destroy");
	
	document.getElementById("avgscore").value=retData.avgScore;
	$("#avgscore").addClass("rating rating-loading");
	
	//$("#span-cnt").html(data.cnt);
	let span_cnt=document.getElementById("span-cnt");
	console.log("data.cnt="+retData.cnt);
	span_cnt.innerHTML=retData.cnt;
	// 별점목록을 다시 1페이지를 보여준다. 내가 등록한 것이 제일 위에 있다.
	// 테이블에 현재 보여주는 별목록 제거
	$("#tbl_star").html("");
	$("#page").val(0);
	getStar();
	// 페이지의 등록된 값 초기화
	//$("#score").rating("reset");
	$("#score").rating("destroy");
	document.getElementById("score").value=0;
	$("#score").addClass("rating rating-loading");
	$("#cmt").val("");
	$("#cmt").focus();
	
	newStar();
}

	//$(".disp") : 제이쿼리
/*=============================================
* 도서수정버튼은 클릭했을때
*=============================================*/	
	function bookEdit(){
		$(".disp").css("display","none");
		$(".edit").css("display","block");
		//버튼
		$("#btnEdit").css("display","none");
		$("#btnDelete").css("display","none");
		$("#btnSave").css("display","block");
		$("#btnCancle").css("display","block");
		//데이터 값 설정하기
		//document.getElementById("title").value="${vo.title}";
		//document.querySelector("#writer").value="${vo.writer}";
		//document.querySelector("#publisher").value="${vo.publisher}";
		//document.querySelector("#price").value="${vo.price}";
					
	}
	//도서 삭제
	function bookDelete(){
		if(confirm("도서삭제를 수행 하시겠습니까?")){
			location.href="book?cmd=del&bno=${vo.bno}";
		}
	}
	//도서저장
	//function bookSave(){
		//document.querySelector("#uploadForm") 폼태그의 요소가져오기 
	//	document.querySelector("#uploadForm").submit();
	//}
	function bookCancle(){
		$(".disp").css("display","block");
		$(".edit").css("display","none");
		//버튼
		$("#btnEdit").css("display","block");
		$("#btnDelete").css("display","block");
		$("#btnSave").css("display","none");
		$("#btnCancle").css("display","none");
	}
</script>
<%@ include file="../include/footer.jsp" %>