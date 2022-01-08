local tMERichText = {}

function EditLua:createRichText(szId, tParams)
    print("createRichText")
    local rich = TFRichText:create()

    TFRichTextManager:addFont("hbt1", "test/font/mini.ttf")
    TFRichTextManager:addFont("hbt2", "test/font/mini.ttf", 0xFFFFFFFF, 24, TF_FONT_SHADOW, 2, 0xFF0000FF)
    TFRichTextManager:addFont("hbt3", "test/font/mini.ttf", 0xFFFFFFFF, 30)
    TFRichTextManager:addFont("hbt5", "test/font/mini.ttf", 0xFFFFFFFF, 30, TF_FONT_STRENGTHEN, 1, 0xFFFFFFFF)
    TFRichTextManager:addFont("hbt4", "test/font/mini.ttf", 0xFFFFFFFF, 30, TF_FONT_BORDER, 2, 0xFF0000FF)

    TFRichTextManager:addFont("hbt6", "test/font/mini.ttf") -- test font buff
    TFRichTextManager:addFont("hbt7", "test/font/mini.ttf")
    TFRichTextManager:addFont("hbt8", "test/font/mini.ttf")
    TFRichTextManager:addFont("hbt9", "test/font/mini.ttf")
    TFRichTextManager:addFont("hbt10", "test/font/mini.ttf")
    TFRichTextManager:addFont("hbt11", "test/font/mini.ttf")
    TFRichTextManager:addFont("hbt12", "test/font/mini.ttf")
    TFRichTextManager:addFont("hbt13", "test/font/mini.ttf")
    TFRichTextManager:addFont("hbt14", "test/font/mini.ttf")

    rich:setText([[
        <tr><td valign="middle" align="left" width="100%" height="100%">
            <p><font color="#FF00FFFF">默认字体测试:please .. </font></p>
            <p style="text-align:left;line-height:50px; margin:20px; padding:0">
                <font face="hbt2">this is a te<mc src="test/movieclip/1_0.mp" play="auto" anim="default" />stttttt<mc src="test/movieclip/face_jingya.mp" play="auto" anim="default" /><mc src="test/movieclip/face_jingya.mp" play="auto" anim="default" />ttt海豹体<mc src="test/movieclip/face_jingya.mp" play="auto" anim="default" />tttttz这里的位置是margin,也就是行距</font>
            </p>
            <p style="text-align:left; line-height:20px; margin:30px; padding:0;">
                <font face="hbt1" color="#FF0000FF">各种海豹体测试(align:left)test1</font>
            </p>
            <p style="text-align:center; line-height:20px; margin:30px; padding:0;">
                <font face="hbt2" color="#0000FFFF">各种海豹体测试(align:center)test2</font>
            </p>
            <p style="text-align:right; line-height:20px; margin:30px; padding:0;">
                <font face="hbt3" color="#00FF00FF">各种海豹体测试(align:right)test3</font>
            </p>
            <p style="margin:30px;" />
            <p style="text-align:left; line-height:20px; margin:30px; padding:0;">
                <font face="hbt5" color="#00FF00FF">各种海豹体测试test3 strength</font>
            </p>
            <p style="text-align:left; line-height:20px; margin:30px; padding:0;">
                <font face="hbt4" 
                color="#FFFF00FF">各种海豹体测试test4</font>
            </p>
            <p><font color="#FFFF00FF">默认字体测试:please .. 这是测试</font><mc src="test/movieclip/face_jingya.mp" play="auto" anim="default" />测试啊 </p>
            <p>右边是一张图片<img src="test/Icon-57.png"></img>图片结束</p>
            <p>
                <font color="#FFFF00FF">各</font>
                <font color="#FF0000FF">种</font>
                <font color="#FF0FF0FF">字</font>
                <font color="#CC1234FF">体</font>
                <font color="#00FF00FF">颜</font>
                <font color="#FF00FFFF">色</font>
                <font color="#FFFFFFFF">测</font>
                <font color="#FF0FF0FF">试</font>
                <font color="#00FFFFFF">效</font>
                <font color="#FFF000FF">果</font>
            </p>
        </td></tr>
    ]])

    -- tTouchEventManager:registerEvents(rich)
    targets[szId] = rich
    
    EditLua:addToParent(szId, tParams)
    print("createRichText success")
end

return tMERichText