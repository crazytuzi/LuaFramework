
local NODE_TYPE={
	NODE_START_TAG= 1,   --开始标签,如 <a href="liigo.com"> 或 <br/>
	NODE_END_TAG=	2,   --结束标签,如 </a>
	NODE_CONTENT=	3,   --内容: 介于开始标签和/或结束标签之间的普通文本
	NODE_REMARKS=	4,   --注释: <!-- -->
	NODE_UNKNOWN=	5,   --未知的节点类型
}

local TAG_TYPE={
	TAG_A=			11,
	TAG_BR=			28,
	TAG_FONT=		51,
	TAG_HTML=		66,
	TAG_P=			91,
	TAG_TD=			113,
	TAG_ITEM=		151,
	TAG_F=			152,
	TAG_PIC=		153,
	TAG_TASKPIC=	154,
	TAG_TASKNPC=	155,
	TAG_TASKTARGET= 156,
	TAG_LINE=		157,
}

GameUtilBase = {}

function GameUtilBase.split(str,delimiter)    --字符串转换成table
	if delimiter == '' then return false ; end
	local pos,arr = 0,{}
	for st,sp in function() return string.find(str,delimiter,pos,true); end do
		table.insert(arr, string.sub(str, pos, st - 1));
		pos = sp + 1;
	end
	table.insert(arr, string.sub(str, pos));
	return arr;
end

function GameUtilBase.decode(text)
	return json.decode(text)
end

function GameUtilBase.encode(text)
	return json.encode(text)
end

function GameUtilBase.isObjectExist(object)
	if object and not tolua.isnull(object) then return true end
end

local bit=require("bit")
function GameUtilBase.unicode_to_utf8( convertStr )
	if(type(convertStr)~="string") then
		return convertStr
	end

	local resultStr = ""
	local i=1
	while true do
		local num1 = string.byte(convertStr,i)
		local  unicode
		if num1~=nil and string.sub(convertStr,i,i+1)=="\\u" then
			unicode=tostring("0x"..string.sub(convertStr,i+2,i+5))
			i=i+6
		elseif num1~=nil then
				unicode=num1
				i=i+1
		else
			break
		end

		unicode=tonumber(unicode)

		if unicode <=0x007f then
			resultStr=resultStr..string.char(bit.band(unicode,0x7f))
		elseif unicode >= 0x0080 and unicode <=0x07ff then
			resultStr=resultStr..string.char(bit.bor(0xc0,bit.band(bit.rshift(unicode,6),0x1f)))
			resultStr=resultStr..string.char(bit.bor(0x80,bit.band(unicode,0x3f)))
		elseif unicode>=0x0800 and unicode<=0xffff then
			resultStr=resultStr..string.char(bit.bor(0xe0,bit.band(bit.rshift(unicode,12),0x0f)))
			resultStr=resultStr..string.char(bit.bor(0x80,bit.band(bit.rshift(unicode,6),0x3f)))
			resultStr=resultStr..string.char(bit.bor(0x80,bit.band(unicode,0x3f)))
		end

	end
	resultStr=resultStr..'\0'
	-- print(resultStr)
	return resultStr
end

function GameUtilBase.newRichLabel(size,space)
	if not space then
		space = 0
	end
	local richlabel=ccui.RichText:create()
		:ignoreContentAdaptWithSize(false)
		:setContentSize(size)
		:setAnchorPoint(cc.p(0.5,0.5))
		:setVerticalSpace(space)
		:setTouchEnabled(false)
	return richlabel
end

function GameUtilBase.setRichLabel(richlabel,htmltext,parent,tsize,color)
	richlabel:removeAllElement()

	if not parent then
		parent = ""
	end
	htmltext,n=string.gsub(htmltext,"\t"," ")
	htmltext,n=string.gsub(htmltext,"\r","")

	local parser=cc.HtmlParser:new()

	tolua.takeownership(parser)

	parser:parseHtml(htmltext)

	local msize=20
	if tsize then
		msize=tsize
	end

	local brCount = 0
	local tag_a=false
	local index=0
	local Dcolor="0xffffff"
	local Dsize=msize
	local Tcolor = {[1]=color}
	local Tsize = {[1]=msize}
	local TOLcolor = {[1]='0x000000'} -- 描边颜色
	local TOLsize = {[1]=0}	-- 描边size
	local TUnline = {[1]=0}  -- 是否描边 1描边
	local ImageTab = {}
	for i=0,parser:getHtmlNodeCount()-1 do
		local pNode=parser:getHtmlNode(i)
		if pNode:getType()==NODE_TYPE.NODE_START_TAG then
			if pNode:getTagType()~=TAG_TYPE.TAG_BR then
				brCount=0
			end

			if pNode:getTagType()==TAG_TYPE.TAG_FONT then

				local tempcolor=cc.HtmlParser:getAttributeStringValue(pNode,"color","ffffff")
				table.insert(Tcolor,"0x"..string.sub(tempcolor,2))

				local tempsize=cc.HtmlParser:getAttributeIntValue(pNode,"size",msize)
				table.insert(Tsize,tempsize)

				local tempOLcolor=cc.HtmlParser:getAttributeStringValue(pNode,"outline_color","ffffff")
				table.insert(TOLcolor,"0x"..string.sub(tempOLcolor,2))

				local tempOLsize=cc.HtmlParser:getAttributeIntValue(pNode,"outline_size",0)
				table.insert(TOLsize,tempOLsize)

				local tempUnder=cc.HtmlParser:getAttributeIntValue(pNode,"underline",0)
				table.insert(TUnline,tempUnder)
			
			elseif pNode:getTagType()==TAG_TYPE.TAG_TD then
				local width = cc.HtmlParser:getAttributeStringValue(pNode,"width")
				if width then
					width = tonumber(width)
				else
					width=100
				end
				local ccwidget=ccui.Widget:create()
				ccwidget:setContentSize(cc.size(richlabel:getCustomSize().width*width/100,10))
				local element=ccui.RichElementCustomNode:create(index,display.COLOR_WHITE,255,ccwidget)
				richlabel:pushBackElement(element)
				index=index+1
				print("tdddddddddddddddddddddddd",pNode.width)
			elseif pNode:getTagType()==TAG_TYPE.TAG_BR then

				brCount = brCount + 1
				local height = 0
				if brCount >1 then
					height = 10
				end
				local ccwidget=ccui.Widget:create()
				ccwidget:setContentSize(cc.size(richlabel:getCustomSize().width,height))
				local element=ccui.RichElementCustomNode:create(index,display.COLOR_WHITE,255,ccwidget)
				richlabel:pushBackElement(element)
				index=index+1
			elseif pNode:getTagType()==TAG_TYPE.TAG_PIC then
				local function linktouch(pSender)
					GameUtilBase.touchlink(pSender,ccui.TouchEventType.ended,parent,richlabel)
				end

				local picfile = cc.HtmlParser:getAttributeStringValue(pNode,"src")
				local resfile = cc.HtmlParser:getAttributeStringValue(pNode,"res")
				local selfile = cc.HtmlParser:getAttributeStringValue(pNode,"sel")
				
				if resfile and tostring(resfile)~="" then
					local img = ccui.Button:create()
					img:setTitleFontName(FONT_NAME)
					img:loadTextureNormal(tostring(resfile),ccui.TextureResType.plistType)
					if selfile then
						img:loadTexturePressed(tostring(selfile),ccui.TextureResType.plistType)
					end

					local fs = cc.HtmlParser:getAttributeStringValue(pNode,"fs")
					if fs then
						img:setTitleFontSize(tonumber(fs))
					end
					local tcolor = cc.HtmlParser:getAttributeStringValue(pNode,"tcolor")
					if tcolor then
						local param = string.split(tostring(tcolor), "|")
						if #param == 3 then
							img:setTitleColor(cc.c3b(tonumber(param[1]), tonumber(param[2]), tonumber(param[3])))
						end
					end
					local text = cc.HtmlParser:getAttributeStringValue(pNode,"text")
					if text then
						img:setTitleText(tostring(text))
					end
					local ss = cc.HtmlParser:getAttributeStringValue(pNode,"ss")
					if ss then
						img:setScale9Enabled(true)
					end

					local opa = cc.HtmlParser:getAttributeStringValue(pNode,"opa")
					if opa then
						img:setOpacity(255 * tonumber(opa))
					end
					
					-- 图片超链接
					local link = cc.HtmlParser:getAttributeStringValue(pNode,"href")
					if link then
						img.user_data=link
						img:setTouchEnabled(true)
						img:addClickEventListener(function ( sender )
							linktouch(sender)
						end)
					end
					
					local element=ccui.RichElementCustomNode:create(index,cc.c3b(255,255,255),0,img)
					richlabel:pushBackElement(element)
					richlabel:setTouchEnabled(true)
					index=index+1
				elseif picfile and tostring(picfile)~="" then
					local img = ccui.ImageView:create(tostring(picfile),ccui.TextureResType.plistType)

					local em = string.find(tostring(picfile),"^em_") --匹配开头
					if em then
						-- img:setContentSize(img:getVirtualRendererSize())
						img:setScale(0.7)  --表情缩放70%
						-- img:setContentSize(img:getContentSize().width*0.7,img:getContentSize().height*0.7)
					end

					-- 图片超链接
					local link = cc.HtmlParser:getAttributeStringValue(pNode,"href")
					if link then
						img.user_data=link
						img:setTouchEnabled(true)
						img:addClickEventListener(function ( sender )
							linktouch(sender)
						end)
					end
					
					local element=ccui.RichElementCustomNode:create(index,cc.c3b(255,255,255),0,img)
					richlabel:pushBackElement(element)
					richlabel:setTouchEnabled(true)
					index=index+1
				end
			elseif pNode:getTagType()==TAG_TYPE.TAG_P then
				brCount = brCount + 1
				local height = 0
				if brCount >1 then
					height = 10
				end
				tag_a=true
				local ccnode = parser:getHtmlNode(i+1)
				if ccnode:getType() == NODE_TYPE.NODE_CONTENT then
					local function linktouch(pSender,touch_type)
						-- if touch_type == ccui.TouchEventType.ended then
							GameUtilBase.touchlink(pSender,ccui.TouchEventType.ended,parent,richlabel)
						-- end
					end
					local tempStr=ccnode:getText()
					local item_num = ""
					local pos = string.find(tempStr,"##")
					if pos > 0 then
						tempStr = string.sub(tempStr,pos+string.len("##"))
						pos = string.find(tempStr,"##")
						if pos and pos > 0 then
							item_num = string.sub(tempStr,pos+string.len("##"))
							tempStr = string.sub(tempStr,0,pos-1)
						end
					end
					local attrTab = string.split(tempStr,",")
					if tonumber(attrTab[3]) then
						local Image = ccui.ImageView:create()
						Image:loadTexture("img_inputbg.png",ccui.TextureResType.plistType)
						Image:setLocalZOrder(20)
						Image.attrTab = attrTab

						local item = Com_itemById:create()
						item:setID(tonumber(attrTab[3]))
						item:setAnchorPoint(cc.p(0.5,0.5))
						if tonumber(attrTab[24]) then
							item:setQulity(attrTab[24])
						end
						if tonumber(attrTab[28]) then
							item:setStarLv(attrTab[28])
						end
						item:setScale(0.6)

						if attrTab[1] == "jishou" then
							item:setClickCallBack(function (sender)
								if tonumber(attrTab[3]) then
									GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str="panel_market"})
									GameSocket:dispatchEvent({name = GameMessageCode.EVENT_CLOSE_PANEL,str="panel_chat"})
								end
							end)
						end
						item:setPosition(cc.p(Image:getContentSize().width/2,Image:getContentSize().height/2))
						Image:addChild(item)
						table.insert(ImageTab,Image)
						local element=ccui.RichElementCustomNode:create(index,cc.c3b(255,255,0),255,Image)
						richlabel:pushBackElement(element)
						richlabel:setTouchEnabled(true)
						index=index+1
					end
				end
			elseif pNode:getTagType()==TAG_TYPE.TAG_A then
				local link = ""
				local tempunder=0
				if parser:getHtmlNodeCount() > 0 then
					link = cc.HtmlParser:getAttributeStringValue(pNode,"href")
					local under=cc.HtmlParser:getAttributeIntValue(pNode,"underline",0)
					tempunder = under and tonumber(under) or 0
				end

				tag_a=true
				local ccnode = parser:getHtmlNode(i+1)
				if ccnode:getType() == NODE_TYPE.NODE_CONTENT then
					local function linktouch(pSender)
						-- if touch_type == ccui.TouchEventType.ended then
							GameUtilBase.touchlink(pSender,ccui.TouchEventType.ended,parent,richlabel)
						-- end
					end
					local tempStr=ccnode:getText()
					tempStr=GameBaseLogic.clearHtmlText(tempStr)
					local label = GameUtilBase.newUILabel({
						text = tempStr,
						fontSize = Tsize[#Tsize],
						color = cc.c3b(255,0,0),
					})
					if tempunder == 1 then
						label:enableUnderline(true)  --下划线
					end
					label:setTouchEnabled(true)
					label.user_data=link
					label:addClickEventListener(function ( sender )
						linktouch(sender)
					end)

					if tempStr == "ui_accept_task" or tempStr == "ui_done_task" then
						local param = {}
						param[1] = tempStr
						param[2] = label
						label:setVisible(false)
						label:setTouchEnabled(false)
						richlabel.param = param
					end

					local element=ccui.RichElementCustomNode:create(index,cc.c3b(255,255,0),255,label)
					richlabel:pushBackElement(element)
					richlabel:setTouchEnabled(true)
					index=index+1
				end
			end
		elseif pNode:getType()==NODE_TYPE.NODE_CONTENT then
			if tag_a then
				tag_a=false
			else
				local text=pNode:getText()
				if text then
					local tempStr=GameBaseLogic.clearHtmlText(text)
					local tcolor=Dcolor
					if tonumber(Tcolor[#Tcolor]) then tcolor=tonumber(Tcolor[#Tcolor]) end

					local tOLcolor = '0x000000'
					if TOLcolor[#TOLcolor] and tonumber(TOLcolor[#TOLcolor]) then tOLcolor = tonumber(TOLcolor[#TOLcolor]) end
					local tOLsize = 0
					if TOLsize[#TOLsize] and tonumber(TOLsize[#TOLsize]) then tOLsize = tonumber(TOLsize[#TOLsize]) end
					local tUnline = false
					if TUnline[#TUnline] and tonumber(TUnline[#TUnline]) then tUnline = tonumber(TUnline[#TUnline])==1 and true or false end

					local aaa=GameBaseLogic.c3b_to_c4b(GameBaseLogic.getColor(tOLcolor),150)
					-- print(Tcolor[#Tcolor],tempStr,TOLcolor[#TOLcolor],"ccccccccc")
					local element=ccui.RichElementText:create(index, GameBaseLogic.getColor(tcolor), 255, tempStr, FONT_NAME, Tsize[#Tsize], GameBaseLogic.c3b_to_c4b(GameBaseLogic.getColor(tOLcolor),150), tOLsize)--,tUnline)
					richlabel:pushBackElement(element)
					index=index+1
				end
			end
		elseif pNode:getType()==NODE_TYPE.NODE_END_TAG then
			if pNode:getTagName()=="font" then
				table.remove(Tcolor,#Tcolor)
				table.remove(Tsize,#Tsize)
				table.remove(TOLsize,#TOLsize)
				table.remove(TOLcolor,#TOLcolor)
			end
		end
	end
	richlabel:formatText()
	for i=1,#ImageTab do
		if ImageTab[i].item then
			ImageTab[i].item:setPosition(ImageTab[i]:getPositionX()+richlabel:getContentSize().width/2+ImageTab[i]:getContentSize().width/2,ImageTab[i]:getPositionY()/2)
		end
	end
	--richlabel:setPosition(cc.p(0,richlabel:getRealHeight()))
	richlabel:setPosition(cc.p(0,0))
end

function GameUtilBase.setTimeFormat(milliSecond , typeT)
	local day = math.floor(milliSecond / 3600000 / 24)
	local hour = math.floor(milliSecond%(3600000*24) / 3600000)
	local minute = math.floor(milliSecond%3600000 / 60000)
	local second = math.floor(milliSecond % 60000 / 1000)
	local milliSecondStr = math.floor(milliSecond % 1000)
	local str = ""
	if not typeT then
		if day >0 then str = str..day.."天" end
		if hour>0 then str = str..hour.."时" end
		if minute>0 then str = str..minute.."分" end
		if second>0 then str = str..second.."秒" end
	elseif typeT == 1 then
		str = minute.."分"..second.."秒"
	elseif typeT == 2 then
		str = string.format("%02d:%02d:%02d",hour,minute,second)
		-- str = (hour >= 10 and hour or "0" ..hour) ..":"..(minute >= 10 and minute or "0" ..minute)..":"..(second >= 10 and second or "0" ..second)
	elseif typeT == 3 then
		str = string.format("%02d:%02d",minute,second)
		-- str = (minute >= 10 and minute or "0" ..minute)..":"..(second >= 10 and second or "0" ..second)
	elseif typeT == 4 then
		str = string.format("%02d时%02d分%02d秒",hour,minute,second)
		-- str = hour.."时"..minute.."分"..second.."秒"
	elseif typeT == 5 then
		str = {day , hour , minute , second , milliSecondStr}
	elseif typeT == 6 then
		str = string.format("%02d天%02d时%02d分",day,hour,minute)
		-- str = day.."天"..(hour%24) .."时"..minute.."分"
	elseif typeT == 7 then
		str = string.format("%02d时%02d分",hour,minute)
		-- str = hour.."时"..minute.."分"
	elseif typeT == 8 then
		if day>0 then
			str = day.."天"..(hour >= 10 and hour or "0" ..hour) .."小时"..(minute >= 10 and minute or "0" ..minute).."分"..(second >= 10 and second or "0" ..second).."秒"
		else
			str = (hour >= 10 and hour or "0" ..hour) .."小时"..(minute >= 10 and minute or "0" ..minute).."分"..(second >= 10 and second or "0" ..second).."秒"
		end
	end	
	return str
end

function GameUtilBase.updateNamePos(nameSprite)
	if GameUtilBase.isObjectExist(nameSprite) then
		local mVipSprite = nameSprite:getChildByName("mVipSprite")
		local mNameLabel = nameSprite:getChildByName("mNameLabel")
		if mVipSprite then
			local nameWidth = mNameLabel:getContentSize().width
			local vipWidth = mVipSprite:getContentSize().width
			mVipSprite:setPositionX(- 0.5 * (nameWidth + vipWidth))
			-- mNameLabel:setPositionX(vipWidth * 0.5)
		end
	end
end