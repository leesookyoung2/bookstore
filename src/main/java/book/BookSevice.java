package book;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.oreilly.servlet.MultipartRequest;
import com.oreilly.servlet.multipart.DefaultFileRenamePolicy;

import util.PageVO;

public class BookSevice {
	private HttpServletRequest request;
	private HttpServletResponse response;
	private final String path="/WEB-INF/jsp/book/";
	public BookSevice(HttpServletRequest request, HttpServletResponse response) {
		this.request=request;this.response=response;
	}

	public String exec() throws IOException {
		String cmd=request.getParameter("cmd");
		String view =null;
		if(cmd.equals("list"))
			view=BookListService();
		else if(cmd.equals("view"))
			view=BookViewService();
		else if(cmd.equals("new"))
			view=BookNewService();
		else if(cmd.equals("edit"))
			view=BookUpdateService();
		else if(cmd.equals("del"))
			view=BookDeleteService();
		else if(cmd.equals("imgDown"))
			BookImgDownService();
		return view;
	}

	private void BookImgDownService() throws IOException {
		// 파라메타값 받아오기
		String originFname=request.getParameter("originFname");//원본파일명
		String upload=request.getParameter("upload");//경로
		String saveFname=request.getParameter("saveFname");//저장된 파일명
		String filename=upload+"/"+saveFname;
		System.out.println("filename="+filename);
		//웹브라우저의 종류 확인
		String agent=request.getHeader("User-Agent");
		System.out.println(agent);
		// ie 7 또는 edge
		boolean ieBrowser=(agent.indexOf("Trident")>-1)||(agent.indexOf("Edge")>-1);
		if(ieBrowser) {
			try {
				originFname=URLEncoder.encode(originFname,"utf-8").replace("\\","%20");
			} catch (UnsupportedEncodingException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}else {// edge, 파이어폭스, 크롬
			try {
				originFname=new String(originFname.getBytes("utf-8"),"iso-8859-1");
			} catch (UnsupportedEncodingException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		response.setContentType("image/jpg");
		//다운로드 되는 파일명 설정
		response.setHeader("Content-Disposition", "attachment;filename="+originFname);
		FileInputStream in=null;
		try {
			in = new FileInputStream(filename);
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}//파일 open
		//출력할 곳
		BufferedOutputStream out=new BufferedOutputStream(response.getOutputStream());
		int numRead;
		byte b[]=new byte[4096];//4K만큼
		while((numRead=in.read(b,0,b.length))!=-1) {
			out.write(b,0,numRead);
		}//end while
		out.flush();//버퍼에 남은것 출력
		in.close();
		out.close();
	}

	private String BookDeleteService() {
		//파라메타 받기
				int bno=Integer.parseInt(request.getParameter("bno"));
				//dao 객체생성
				BookDAO dao=BookDAO.getInstance();
				//dao 메소드 구현
				int result=dao.deleteBook(bno);
				if(result==1) {//삭제 완료
					return "book?cmd=list";
				}
		return null;
	}

	private String BookUpdateService() {
		String upload="d:/upload/img";
		//mr 객체만 생성하면 mr안에 모든 넘어온 파라메타가 다 저정되고, 업로드 파일이 있으면 파일 저장폴더에 저장 된다
		MultipartRequest mr=null;
		try {
			mr = new MultipartRequest(request, upload, 2*1024*1024
					, "utf-8", new DefaultFileRenamePolicy());
			// 넘어오는 데이터를 받아서 수정작업
			// MultipartRequest  사용 
			// 첨부파일 있는지 없는지 확인?? 있다면 수정, 없다면 수정 x
			if(mr!=null) {
				//System.out.println("mr.getOriginalFileName="+mr.getOriginalFileName("file"));
				//System.out.println("mr.getFilesystemName="+mr.getFilesystemName("file"));
				// BookVO 넘어온 데이터를 담고 수정작업
				//넘어온 데이터 받기
				//bno 받기
				int bno=Integer.parseInt(mr.getParameter("bno"));
				String title=mr.getParameter("title").trim();
				String writer=mr.getParameter("writer").trim();
				String publisher=mr.getParameter("publisher").trim();
				String content=mr.getParameter("content").trim();
				int price=Integer.parseInt(mr.getParameter("price"));
				String oFileName=mr.getOriginalFileName("file");
				if(oFileName==null)upload=null;
				BookVO vo=new BookVO(bno,title, writer, price, publisher
						, content,oFileName
						,mr.getFilesystemName("file"),upload);
				//dao 객체 만들기
				BookDAO dao=BookDAO.getInstance();			
				//dao 수정 메소드 호출 
				int result=dao.updateBook(vo);
				if(result==1) {//업데이트 완료		
					return "book?cmd=view&bno="+bno;
				}
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
		return null;
	}

	private String BookNewService() {
		if(request.getMethod().equals("GET")){
			return path+"bookNew.jsp";
		}else {
			//업로드 폴더 설정
			String uploadPath="d:/upload/img";
			File path=new File(uploadPath);
			if(!path.exists()) {//폴더가 없으면 폴더 만들기
				path.mkdirs();
			}
			// MultipartRequest 객체 생성하면 파일업로드 완료
			MultipartRequest mr=null;
			try {
				mr = new MultipartRequest(request, uploadPath,2*1024*1024, "utf-8", new DefaultFileRenamePolicy());
				if(mr!=null) {
					//넘어온 데이터 받기
					String title=mr.getParameter("title").trim();
					String writer=mr.getParameter("writer").trim();
					String publisher=mr.getParameter("publisher").trim();
					String content=mr.getParameter("content").trim();
					int price=Integer.parseInt(mr.getParameter("price"));
					//System.out.println(title);
					//VO 객체에 넘어온 데이터 저장
					BookVO vo=new BookVO(title, writer, price, publisher, content
							,mr.getOriginalFileName("file")
							,mr.getFilesystemName("file"),uploadPath);
					//dao 객체 생성
					BookDAO dao=BookDAO.getInstance();
					//dao 객체 insertBook 메소드 수행
					int result=dao.insertBook(vo);
					//페이지이동 리스트 
					if(result==1) {//삽입완료 - 전체목록 이동 
						return "book?cmd=list";
					}
				}
			} catch (IOException e) {
				e.printStackTrace();
			}
			
			return null;
		}
	}

	private String BookViewService() {
		//파라메타 받기  bno
		int bno=Integer.parseInt(request.getParameter("bno"));
		//페이지 관련 정보 받아서
		String strpage=request.getParameter("page");
		int page=1;
		if(strpage!=null)page=Integer.parseInt(strpage);
		String searchword=request.getParameter("searchword");
		String searchtype=request.getParameter("searchtype");
		//System.out.println("bView");
		//dao 객체 생성
		BookDAO dao=BookDAO.getInstance();
		//dao 메소드 호출 결과 받기 : BookVO (모든 필드 다 담겨있어야 한다)
		BookVO vo=dao.getBook(bno);
		//페이지 이동전 jsp 필요한데이터를 setAttribute로 담는다
		if(vo!=null) {//조회 완료

			request.setAttribute("vo", vo);
			//page관련정보 담는다
			request.setAttribute("page", page);
			request.setAttribute("searchword", searchword);
			request.setAttribute("searchtype", searchtype);			
			return path+"bookView.jsp";			
		}else 
		return null;
	}

	private String BookListService() {
		BookDAO dao=BookDAO.getInstance();
		//List<BookVO> list=dao.getBookList();// 전체 행을 출력	
		//페이징을 위한 변수 선언
		//parmaPage : 파라메타(?뒤에 ?page=${i})---현재 페이지 설정
		String parmaPage=request.getParameter("page");
		int page=0;
		if(parmaPage==null)page=1;
		else page=Integer.parseInt(parmaPage);
		
		int displayRow=5;
		int displayPage=5;
		int rowCnt=0;
		List<BookVO> list=null;
		
		//검색어 관련 파라메타 받아서 저장
		String searchtype=request.getParameter("searchtype");
		String searchword=request.getParameter("searchword");;
		System.out.println("searchtype="+searchtype);
		if(searchword==null || searchword.equals("")) {
			list=dao.getBookList(page,displayRow);
			rowCnt=dao.getRowConut();//booktbl 전체 행의 개수
		}else {//검색어 있음
			//searchtype=
			list=dao.getBookList(page,displayRow,searchtype,searchword);
			rowCnt=dao.getRowConut(searchtype,searchword);//booktbl 해당검색어가 있는 전체 행의 개수
		}
		
		// PageVO 객체 생성
		PageVO pVo=new PageVO(page,rowCnt,displayRow,displayPage);
		pVo.setSearchword(searchword);//검색어를 PageVO 객체에 저장
		pVo.setSearchtype(searchtype);
		//pVo.setPage(page);//page설정
		//pVo.setPage(6);
		//pVo.setTotalCount(rowCnt);
		//브라우저에서 접근가능한 객체에 list 저장
		request.setAttribute("list", list);
		request.setAttribute("pVo", pVo);
		//페이지이동 webapp/book/booklist.jsp
		return path+"booklist.jsp";
	}

}
