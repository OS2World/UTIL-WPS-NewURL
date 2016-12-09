/* ---------------------------------------------------------------------------
 NewUrl - Version 0.3
 PROGRAM INITIALIZATION
 g.parameters contains the program startup parameters!
--------------------------------------------------------------------------- */

InitApplication:

   /* translate these strings to implement a different NLV of NewUrl */
   g.t.dlgTitle = "URL object creation"
   g.t.prepend = "Prepend to URL: "
   g.t.nothing = "~Nothing"
   g.t.http = "~http://"
   g.t.ftp = "~ftp://"
   g.t.urlFromClip = "~URL from clipboard"
   g.t.titleFromClip = "~Title from clipboard"
   g.t.titleFromUrl = "Titl~e from URL"
   g.t.url = "URL:"
   g.t.title = "Title:"
   g.t.ok = "~Ok"
   g.t.cancel = "~Cancel"
   g.error.1 = "Failed to create "
   g.error.2 = " in "
   /* end of translatable text strings */

   call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
   call SysLoadFuncs
   g.prepend = ""
   g.urlEntry = ""
   g.titleEntry = ""
   parse source . . src
   g.inifile = fileNameStripExtension(src)".ini"
   g.cxini = SysIni(g.inifile, "newurl", "width");
   if "ERROR:" = g.cxini then
      g.cxini = 0;
return


/* ---------------------------------------------------------------------------
 dialog initialization
*/
MainDlg.Init:

   /* update the text of the controls */
   call setDlgCaptions
   /* if the clipboard contains an URL uses it to initialize the fields */
   url = getUrlFromClipBoard(1);
   title = getTitleFromUrl(url);

   if ("" \= title) then do
      call MainDlg.EfUrl.Text url
      call MainDlg.EfTitle.Text title
      call MainDlg.BtnOk.Enable
      g.urlEntry = url
      g.titleEntry = title
   end

   call MainDlg.RdBtnNothing.Select 1;
   /* store the position and size of the dialog and of the entry fields */
   parse value MainDlg.Position() with g.x g.y g.cx g.cy
   parse value MainDlg.EfUrl.Position() with g.x1 g.y1 g.cx1 g.cy1
   parse value MainDlg.EfTitle.Position() with g.x2 g.y2 g.cx2 g.cy2
   /* store the position of the other controls */
   parse value MainDlg.GrpPrepend.Position() with g.x3 g.y3 .
   parse value MainDlg.RdBtnNothing.Position() with g.x4 g.y4 .
   parse value MainDlg.RdBtnHttp.Position() with g.x5 g.y5 .
   parse value MainDlg.RdBtnFtp.Position() with g.x6 g.y6 .
   parse value MainDlg.LabelUrl.Position() with g.x7 g.y7 .
   parse value MainDlg.LabelTitle.Position() with g.x8 g.y8 .
   parse value MainDlg.BtnUrlFromClipbrd.Position() with g.x9 g.y9 .
   parse value MainDlg.BtnTitleFromClipbrd.Position() with g.x10 g.y10 .
   parse value MainDlg.BtnTitleFromUrl.Position() with g.x11 g.y11 .
   parse value MainDlg.BtnOk.Position() with g.x12 g.y12 .
   parse value MainDlg.BtnCancel.Position() with g.x13 g.y13 .
   /* restore a previously saved dialog width if present */
   if g.cxini > g.cx then do
      call MainDlg.Position g.x, g.y, g.cxini, g.cy
      cxx = g.cxini
      end
   else
      cxx = g.cx
   /* center the dialog */
   parse value MainDlg.Frame() with l b r t
   x = g.x - cxx % 2;
   if x < -l then
      x = -l;
   y = g.y - g.cy % 2;
   if y < -b then
      y = -b;

   call MainDlg.Position x, y
   call MainDlg.Show

return

/* ---------------------------------------------------------------------------
 the dialog is being moved : store the new coordinates
*/
MainDlg.Move: procedure expose g.
   parse value MainDlg.Position() with xx yy cxx cyy
   if cyy = g.cy then
      g.y = yy
   g.x = xx
return

/* ---------------------------------------------------------------------------
 the dialog is being sized : allow only horizontal resizing
*/
MainDlg.Size: procedure expose g.
   parse value MainDlg.Position() with xx yy cxx cyy
   if cyy > g.cy then do
      cyy = g.cy
      call MainDlg.Position xx yy cxx cyy
      call MainDlg.GrpPrepend.Position g.x3 g.y3
      call MainDlg.RdBtnNothing.Position g.x4 g.y4
      call MainDlg.RdBtnHttp.Position g.x5 g.y5
      call MainDlg.RdBtnFtp.Position g.x6 g.y6
      call MainDlg.LabelUrl.Position g.x7 g.y7
      call MainDlg.LabelTitle.Position g.x8 g.y8
      call MainDlg.BtnUrlFromClipbrd.Position g.x9 g.y9
      call MainDlg.BtnTitleFromClipbrd.Position g.x10 g.y10
      call MainDlg.BtnTitleFromUrl.Position g.x11 g.y11
      call MainDlg.BtnOk.Position g.x12 g.y12
      call MainDlg.BtnCancel.Position g.x13 g.y13
   end
   if cxx \= g.cx then do
      dx = cxx - g.cx
      g.cx1 = g.cx1 + dx
      g.cx2 = g.cx2 + dx
      call MainDlg.EfUrl.Position g.x1, g.y1, g.cx1, g.cy1
      call MainDlg.EfTitle.Position g.x2, g.y2, g.cx2, g.cy2
      g.cx = cxx
   end
return

/* ---------------------------------------------------------------------------
 the dialog is being closed
*/
MainDlg.Exit:
   call SysIni g.inifile, "newurl", "width", g.cx
return

/* ---------------------------------------------------------------------------
 click on 'Nothing' radio button
*/
MainDlg.RdBtnNothing_Click:
   g.prepend = ""
return

/* ---------------------------------------------------------------------------
 click on 'http://' radio button
*/
MainDlg.RdBtnHttp_Click:
   g.prepend = "http://"
return

/* ---------------------------------------------------------------------------
 click on 'ftp://' radio button
*/
MainDlg.RdBtnFtp_Click:
   g.prepend = "ftp://"
return

/* ---------------------------------------------------------------------------
 click on the 'URL from clipboard' button.
*/
MainDlg.BtnUrlFromClipbrd_Click:

   rc = MainDlg.EfUrl.Text(getUrlFromClipBoard(0));
   call MainDlg.EfUrl_Changed

return

/* ---------------------------------------------------------------------------
 click on the 'Title from clipboard' button.
*/
MainDlg.BtnTitleFromClipbrd_Click:

   title = clipboard();

   rc = MainDlg.EfTitle.Text(title);
   call MainDlg.EfTitle_Changed

return

/* ---------------------------------------------------------------------------
 click on the 'Title from URL' button.
*/
MainDlg.BtnTitleFromUrl_Click:

   title = getTitleFromUrl(g.urlEntry);
   rc = MainDlg.EfTitle.Text(title);
   call MainDlg.EfTitle_Changed
return

/* ---------------------------------------------------------------------------
 the text of the URL entry field changed
*/
MainDlg.EfUrl_Changed:

   g.urlEntry = MainDlg.EfUrl.Text();
   call enableButtons

return

/* ---------------------------------------------------------------------------
 the text of the title entry field changed
*/
MainDlg.EfTitle_Changed:

   g.titleEntry = MainDlg.EfTitle.Text();
   call enableButtons

return

/* ---------------------------------------------------------------------------
 Ok button click
*/
MainDlg.BtnOk_Click:
   class = "WPUrl";
   title = g.titleEntry;
   location = directory();
   setup = "URL="g.prepend""g.urlEntry;
   option = "F";
   if (\ SysCreateObject(class, title, location, setup, option)) then do
      msg = g.error.1"title"g.error.2""location
      call RxMessageBox msg, , "OK", "ERROR"
      end
   else
      call MainDlg.close
return

/* ---------------------------------------------------------------------------
 Cancel button click
*/
MainDlg.BtnCancel_Click:
   call MainDlg.close
return

/* ---------------------------------------------------------------------------
 get the URL text from the clipboard
*/
getUrlFromClipBoard: procedure

   parse arg validateUrl
   cliptxt = clipboard();
   select
      when "<http://" = left(cliptxt, 8) | "<ftp://" = left(cliptxt, 7) then do
         cliptxt = translate(cliptxt, "  ", "0d0a"x);
         cliptxt = space(cliptxt, 0);
         cliptxt = substr(cliptxt, 2);
         cliptxt = strip(cliptxt, "T", ">");
      end
      when "http://" = left(cliptxt, 7) | "ftp://" = left(cliptxt, 6) then do
         cliptxt = translate(cliptxt, "  ", "0d0a"x);
         cliptxt = space(cliptxt, 0);
         cliptxt = strip(cliptxt, "T", ">");
      end
      when "www." = left(cliptxt, 4) then do
         cliptxt = translate(cliptxt, "  ", "0d0a"x);
         cliptxt = space(cliptxt, 0);
         cliptxt = "http://"cliptxt
      end
      otherwise
         if validateUrl then
            return ""
   end

return cliptxt


/* ---------------------------------------------------------------------------
 get the title of the Url object from the url content
*/
getTitleFromUrl: procedure

   parse arg url

   if url = "" then
      return ""

   parse var url . "://" site "/" rest

   if site = "" then
      return url

   if rest \= "" then do
      slashpos = lastpos("/", rest);
      if slashpos = "" then
         title = site"/"rest
      else
         title =  site"/.../"substr(rest, slashpos + 1);
      end
   else
      title = site;

return title

/* ---------------------------------------------------------------------------
 enable or disable controls according to the state of the entry fields
*/
enableButtons: procedure expose g.

   if (g.urlEntry \= "") then do
      call MainDlg.BtnTitleFromUrl.Enable
      if (g.titleEntry \= "") then
         call MainDlg.BtnOk.Enable
      else
         call MainDlg.BtnOk.Disable
      end
   else
      call MainDlg.BtnTitleFromUrl.Disable

return

/* ---------------------------------------------------------------------------
 set the text of the dialog and of the controls
*/
setDlgCaptions: procedure expose g.
   call MainDlg.text g.t.dlgTitle
   call MainDlg.GrpPrepend.text g.t.prepend
   call MainDlg.RdBtnNothing.text g.t.nothing
   call MainDlg.RdBtnHttp.text g.t.http
   call MainDlg.RdBtnFtp.text g.t.ftp
   call MainDlg.BtnUrlFromClipbrd.text g.t.urlFromClip
   call MainDlg.BtnTitleFromClipbrd.text g.t.titleFromClip
   call MainDlg.BtnTitleFromUrl.text g.t.titleFromUrl
   call MainDlg.LabelUrl.text g.t.url
   call MainDlg.LabelTitle.text g.t.title
   call MainDlg.BtnOk.text g.t.ok
   call MainDlg.BtnCancel.text g.t.cancel
return

/* ------------------------------------------------------------------------ */
fileNameStripExtension: procedure
parse arg filename

return left(filename, lastpos(".", filename) - 1);

