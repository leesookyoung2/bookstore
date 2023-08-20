<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ include file="../include/header.jsp" %>     
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
<form action="bEdit" method="post"  enctype="multipart/form-data" id="uploadForm" name="uploadForm" >
	<input type="hidden" value="${vo.bno}" name="bno">
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
				String content=vo.getContent();
				if(content!=null)
					out.write(content.replaceAll("\r\n", "<br>"));
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
					<img src="imgDown?upload=${vo.savePath}&saveFname=${vo.saveFilename}&originFname=${vo.srcFilename}" alt="" height="300px">
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
	</table>
	<div class="btn_rud">
		<button type="button" id="btnList" onclick="location.href='bList?page=${page}&searchword=${searchword}&searchtype=${searchtype}'" class="btn btn-success" >도서목록</button>
		<c:if test="${sessionScope.mvo.grade=='a'}">
			<button type="button" id="btnEdit" onclick="bookEdit()" class="btn btn-warning" >도서수정</button>
	 		<button type="button" id="btnDelete" onclick="bookDelete()" class="btn btn-danger" >도서삭제</button> 
	 		<button type="submit" id="btnSave" class="btn btn-primary" style="display:none;">도서저장</button> 
	 		<button type="reset" id="btnCancle" onclick="bookCancle()" class="btn btn-info" style="display:none;">수정취소</button>
 		</c:if> 
    </div>
	</form>

</main>
<script type="text/javascript">
	//$(".disp") : 제이쿼리
	//도서수정버튼은 클릭했을때
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
			location.href="bDelete?bno=${vo.bno}";
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