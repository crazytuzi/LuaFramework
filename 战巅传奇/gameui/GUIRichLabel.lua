local GUIRichLabel = class("GUIRichLabel",function()
	return ccui.Widget:create()
end)
------------------------
-- 颜色标签 <font color=#ffooff>****</font>
-- 超链接 <a href='' color=''>****</a> 
-- 描边"<a outline=\'24,19,11,200,0\'>****</a>"
-- 图片 <pic href='' src=''>****</pic>
-- 表格 <td width=''>****</td>
-- <p>##****##</p>
-- <item src='' >
-- 动画<effect id='' ></effect>
-----------------------
function GUIRichLabel:ctor(params)
	self.space = params.space
	self.size  = params.size
	self.ignoreSize = params.ignoreSize or false
	self.anchor = params.anchor or cc.p(0,0)
	if not self.space then
		self.space = 0
	end
	if not self.size then
		self.size = cc.size(20,20)
	end

	if params.outline and #params.outline == 5 then
		self._outline = params.outline
	end

	if params.shadowColor then
		self._shadowColor = params.shadowColor
		self._shadowOffset = cc.size(2, -2)
		self._blurRadius = 0
	end
	if params.shadowOffset then
		self._shadowOffset = params.shadowOffset
	end
	if params.blurRadius then
		self._blurRadius = params.blurRadius
	end

	self.richlabel = ccui.RichText:create()
	self.richlabel:ignoreContentAdaptWithSize(self.ignoreSize)
	if not self.ignoreSize then
		self.richlabel:setContentSize(self.size)
		self:setContentSize(self.size)
	end
	self.richlabel:setAnchorPoint(cc.p(0,0))
	self.richlabel:setVerticalSpace(self.space)

	if params.name then
		self:setName(params.name)
	end

	self:setAnchorPoint(self.anchor)
	self:addChild(self.richlabel)
	self.richlabel:setCascadeOpacityEnabled(true)
	self:setCascadeOpacityEnabled(true)
end

function GUIRichLabel:setVerticalSpace(space)
	if space then
		self.space = space
		self.richlabel:setVerticalSpace(self.space)
	end
end

function parserHtml(htmltext)
	--去标签
	htmltext,n=string.gsub(htmltext,"\t"," ")
	htmltext,n=string.gsub(htmltext,"\r","")
	-- htmltext,n=string.gsub(htmltext,"%c","<br>")
	
	htmltext,n=string.gsub(htmltext,"<td>(.-)</td>","%1")
	htmltext,n=string.gsub(htmltext,"<font>(.-)</font>","%1")
	htmltext,n=string.gsub(htmltext,"<a>(.-)</a>","%1")
	htmltext,n=string.gsub(htmltext,"<pic>(.-)</pic>","%1")
	htmltext,n=string.gsub(htmltext,"<effect>(.-)</effect>","%1")

	local spos=1
	local epos=1
	local len=string.len(htmltext)
	local tagstr
	local tags={}
	while spos and spos<= len do
		spos,epos,tagstr=string.find(htmltext,"<(.-)>",spos)
		if spos and epos and tagstr then
			table.insert(tags,{spos=spos,epos=epos,tagstr=tagstr})
		end
		if spos and epos then
			spos=epos
		end
	end

	local function parserTag(nodetag)
		local type="start"
		local tstr=""
		local s,e
		if string.sub(nodetag,1,1)=="/" then
			type="end"
			tstr=string.sub(nodetag,2)
		else
			s,e=string.find(nodetag," ")
			if s then
				tstr=string.sub(nodetag,1,s-1)
			elseif string.lower(nodetag)=="p" then
				tstr="p"
			elseif string.lower(nodetag)=="br" then
				tstr="br"
			else
				return
			end
		end

		tstr=string.lower(tstr)

		local node={type=type,tag=tstr}
		if tstr=="font" or tstr=="a" or tstr=="pic" or tstr=="p" or tstr =="item" or tstr =="td" or tstr =="effect" then
			if s and e and type=="start" then
				nodetag=string.sub(nodetag,s+1)
				nodetag=nodetag..">"
				for k,v in string.gmatch(nodetag,"(.-)=(.-)[%s%>]") do
					attr=string.gsub(v,"[\'\"%s]","")
					if string.sub(attr,string.len(attr))=="/" then
						attr=string.sub(attr,1,string.len(attr)-1)
					end
					node[string.lower(k)]=attr
				end
			end
		elseif tstr=="br" then

		else
			return
		end
		return node
	end
	local result={}

	if #tags<=0 then
		table.insert(result,{type="content",text=htmltext})
	else
		for i,v in ipairs(tags) do
			if i==1 then
				if v.spos>1 then
					table.insert(result,{type="content",text=string.sub(htmltext,1,v.spos-1)})
				end
				local node=parserTag(v.tagstr)
				if node then
					table.insert(result,node)
				end
			else
				if tags[i-1] and (v.spos-1)>=(tags[i-1].epos+1) then
					table.insert(result,{type="content",text=string.sub(htmltext,tags[i-1].epos+1,v.spos-1)})
				end
				local node=parserTag(v.tagstr)
				if node then
					table.insert(result,node)
				end
				if i==#tags then
					if v.epos<=len then
						table.insert(result,{type="content",text=string.sub(htmltext,v.epos,len)})
					end
				end
			end
		end
	end
	
	return result
end

function GUIRichLabel:setRichLabel(htmltext,parent,tsize,tcolor)
	self.richlabel:removeAllElement()

	local parser=parserHtml(htmltext)

	local brCount = 0
	local tag_a = false
	local index = 0
	local Dcolor = tcolor or "0xffffff"
	local Dsize = tsize or 20
	local Tcolor = {[1]=Dcolor}
	local Tsize = {[1]=Dsize}
	local Toutline = {}
	-- local count=#parser
	local pNode,pType,pTagType
	for i,v in ipairs(parser) do
		pNode=v
		pType=v.type
		pTagType=v.tag
		if pType=="start" then

			if pTagType~="br" then
				brCount=0
			end

			if pTagType=="font" then

				local tempcolor=Dcolor
				if pNode.color then
					tempcolor=pNode.color
				end
				if string.len(tempcolor)==7 then
					table.insert(Tcolor,"0x"..string.sub(tempcolor,2))
				elseif string.len(tempcolor)==6 then
					table.insert(Tcolor,"0x"..tempcolor)
				end

				local tempsize=Dsize
				if pNode.size then
					tempsize=tonumber(pNode.size)
				end
				if pNode.outline then
					local params = string.split(pNode.outline,",")
					if #params == 5 then
						table.insert(Toutline, params)
					end
				end

				table.insert(Tsize,tempsize or Dsize)

			elseif pTagType=="td" then
				--local ccnode=cc.Node:create()
				--ccnode:setContentSize(cc.size(self.richlabel:getContentSize().width*tonumber(pNode.width)/100,10))
				--local element=ccui.RichElementCustomNode:create(index,display.COLOR_WHITE,255,ccnode,true)
				--self.richlabel:pushBackElement(element)
				--index=index+1
				
				local link = pNode.href or ""
				local tempcolor=Dcolor
				if pNode.color then
					tempcolor=pNode.color
				end
				if string.len(tempcolor)==7 then
					table.insert(Tcolor,"0x"..string.sub(tempcolor,2))
				elseif string.len(tempcolor)==6 then
					table.insert(Tcolor,"0x"..tempcolor)
				end

				tag_a=true
				local ccnode = parser[i+1]
				if ccnode and ccnode.type == "content" and ccnode.text then
					local function linktouch(pSender)
						GameUtilSenior.touchlink(pSender,parent,self.richlabel)
					end
					local tempStr=ccnode.text
					tempStr=GameBaseLogic.clearHtmlText(tempStr)
					local tcolor=Dcolor
					if Tcolor[#Tcolor] then tcolor=tonumber(Tcolor[#Tcolor]) or Tcolor end
					local width = tonumber(pNode.width)
					if not pNode.width then
						width = 100
					end
					local height = tonumber(pNode.size)+3
					if not pNode.size then
						height = Dsize+3
					end
					local label = GameUtilSenior.newUILabel({
						text = tempStr,
						fontSize = pNode.size or Dsize,
						color = GameBaseLogic.getColor(tcolor),
						position = cc.p(320,110),
						contentSize = {width=self.richlabel:getContentSize().width*width/100,height=height}
					})
					label:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
					if pNode.ht then
						if tonumber(pNode.ht) == 0 then
							label:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
						elseif tonumber(pNode.ht) == 1 then
							label:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
						elseif tonumber(pNode.ht) == 2 then
							label:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_RIGHT)
						end
					end
					
					label:setLocalZOrder(10)
					label.user_data=link
					label:setTouchEnabled(true):addClickEventListener(linktouch)
					if self._outline then
						label:enableOutline(cc.c4b(self._outline[1],self._outline[2],self._outline[3],self._outline[4]), self._outline[5])
					end
					if self._shadowColor then
						label:enableShadow(self._shadowColor, self._shadowOffset, self._blurRadius)
					end

					label:setSwallowTouches(false)
					if pNode.underline then
						if string.len(pNode.underline)==7 then
							pNode.underline = "0x"..string.sub(pNode.underline,2)
						elseif string.len(pNode.underline)==6 then
							pNode.underline = "0x"..pNode.underline
						end
						GameUtilSenior.addUnderLine(label, GameBaseLogic.getColor4f(tonumber(pNode.underline, 16)), 1)
					end

					local element=ccui.RichElementCustomNode:create(index,cc.c3b(255,255,0),255,label)
					self.richlabel:pushBackElement(element)
					if tempStr == "ui_accept_task" or tempStr == "ui_done_task" then
						local param = {}
						param[1] = tempStr
						param[2] = label
						label:hide():setTouchEnabled(false)
						self.richlabel.param = param
					end
					index=index+1
				end
				
			elseif pTagType=="br" then

				brCount = brCount + 1
				local height = 0
				if brCount >1 then
					height = 10
				end
				local ccnode=cc.Node:create()
				ccnode:setContentSize(cc.size(self.richlabel:getContentSize().width,height))
				local element=ccui.RichElementCustomNode:create(index,display.COLOR_WHITE,255,ccnode,true)
				self.richlabel:pushBackElement(element)
				index=index+1
			elseif pTagType=="pic" then
				local function linktouchs(pSender)
					GameUtilSenior.touchlink(pSender,parent,self.richlabel)
				end
				local picfile=pNode.src
				local link = pNode.href or ""
				local spriteParent
				
				local resfile = pNode.res
				local selfile = pNode.sel
				
				if resfile and tostring(resfile)~="" then
					local img = ccui.Button:create()
					img:setTitleFontName(FONT_NAME)
					img:loadTextureNormal(tostring(resfile),ccui.TextureResType.plistType)
					if selfile then
						img:loadTexturePressed(tostring(selfile),ccui.TextureResType.plistType)
					end

					local fs = pNode.fs
					if fs then
						img:setTitleFontSize(tonumber(fs))
					end
					local tcolor = pNode.tcolor
					if tcolor then
						local param = string.split(tostring(tcolor), "|")
						if #param == 3 then
							img:setTitleColor(cc.c3b(tonumber(param[1]), tonumber(param[2]), tonumber(param[3])))
						end
					end
					local name = pNode.name
					if name then
						img:setName(tostring(name))
					end
					local text = pNode.text
					if text then
						img:setTitleText(tostring(text))
					end
					
					if pNode.label then
						local node=ccui.Text:create("", FONT_NAME, 20)

						if pNode.fs then
							node:setFontSize(pNode.fs)
						end
						print("============",pNode.label)
						node:setString(pNode.label):show()
						
						if pNode.color then
							local param = string.split(pNode.color, "|")
							if #param == 3 then
								node:setColor(cc.c3b(tonumber(param[1]), tonumber(param[2]), tonumber(param[3])))
							end
						end

						if pNode.width and pNode.height then
							node:ignoreContentAdaptWithSize(false)
							node:setTextAreaSize(cc.size(pNode.width or 0,pNode.height or 0))
							node:setPosition(0,0)
							node:setAnchorPoint(cc.p(0,0))
							node:setContentSize(cc.size(pNode.width or 0,pNode.height or 0))
						end

						node:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
						if pNode.ht then
							if tonumber(pNode.ht) == 1 then
								node:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
							elseif tonumber(pNode.ht) == 2 then
								node:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_RIGHT)
							end
						end
						node:setTextVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_TOP)
						if pNode.vt then
							if tonumber(pNode.vt) == 1 then
								node:setTextVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
							elseif tonumber(pNode.vt) == 2 then
								node:setTextVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_BOTTOM)
							end
						end
						
						img:addChild(node)
					end
					
					local ss = pNode.ss
					if ss then
						img:setScale9Enabled(true)
					end

					local opa = pNode.opa
					if opa then
						img:setOpacity(255 * tonumber(opa))
					end
						
					if pNode.width and pNode.height then
						img:setContentSize(cc.size(tonumber(pNode.width),tonumber(pNode.height)))
						--img:setCapInsets(cc.rect(0, 0, tonumber(pNode.width), tonumber(pNode.height)))
						img:setScale9Enabled(true)
					end
					
					if pNode.color then
						local param = string.split(pNode.color, "|")
						if #param == 3 then
							img:setColor(cc.c3b(tonumber(param[1]), tonumber(param[2]), tonumber(param[3])))
						end
					end
										
					img.user_data=link
					img:setTouchEnabled(true)
					img:addClickEventListener(linktouchs)
					img:setSwallowTouches(false)
					index=index+1
					local element=ccui.RichElementCustomNode:create(index,display.COLOR_WHITE,255,spriteParent or img)
					self.richlabel:pushBackElement(element)
					
				elseif picfile and tostring(picfile)~="" then
					if link =="" then
						local sprite=cc.Sprite:create()
						local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(tostring(picfile))
						if frame then
							sprite:setSpriteFrame(frame)
						end
						if checknumber(pNode.rotation) then
							spriteParent = ccui.Layout:create():setContentSize(sprite:getContentSize())
							sprite:addTo(spriteParent)
							sprite:setAnchorPoint(cc.p(0.5,0.5)):pos(sprite:getContentSize().width/2,sprite:getContentSize().height/2-2):setRotation(checknumber(pNode.rotation))
						end
						-- sprite:setSpriteFrame(tostring(picfile))
						if sprite then
							local element=ccui.RichElementCustomNode:create(index,cc.c3b(255,255,255),0,spriteParent or sprite)
							self.richlabel:pushBackElement(element)
							index=index+1
						end
					else
						local Image = ccui.ImageView:create()
						if string.find(picfile,"%.") then
							--Image:loadTexture(picfile,ccui.TextureResType.localType)
							
							asyncload_callback(picfile, Image, function(filepath, texture)
								Image:loadTexture(filepath)
							end)
						else
							Image:loadTexture(picfile,ccui.TextureResType.plistType)
						end
						if checknumber(pNode.rotation) then
							spriteParent = ccui.Layout:create():setContentSize(Image:getContentSize())
							Image:addTo(spriteParent)
							Image:setAnchorPoint(cc.p(1,1)):pos(Image:getContentSize().width,Image:getContentSize().height):setRotation(checknumber(pNode.rotation))
						end
						Image.user_data=link
						Image:setTouchEnabled(true)
						Image:addClickEventListener(linktouchs)
						Image:setSwallowTouches(false)
						index=index+1
						local element=ccui.RichElementCustomNode:create(index,display.COLOR_WHITE,255,spriteParent or Image)
						self.richlabel:pushBackElement(element)
					end
				end
			elseif pTagType=="p" then

				brCount = brCount + 1
				local height = 0
				if brCount >1 then
					height = 10
				end
				tag_a=true
				local isTypeId = false;
				local ccnode = parser[i+1]
				if ccnode and ccnode.type == "content" and ccnode.text then
					local function linktouch(pSender)
						GameUtilSenior.touchlink(pSender,parent,self.richlabel)
					end
					local tempStr=string.gsub(ccnode.text,"##","")
					local itemColor = cc.c3b(255,255,255)

					local name = tempStr
					local itemdef
					--兼容tempStr为name或者id
					if tonumber(tempStr) then
						isTypeId = true
						itemdef = GameSocket:getItemDefByID(tonumber(tempStr))
					else
						itemdef = GameSocket:getItemDefByName(tempStr)
					end
					if itemdef then
						itemColor = GameBaseLogic.getItemColor(itemdef.mEquipLevel)
						name = itemdef.mName
					end

					local label = GameUtilSenior.newUILabel({
						text = name,
						fontSize = Tsize[#Tsize] or Dsize,
						anchor = cc.p(1,0.5),
						color = itemColor,
						position = cc.p(320,110),
					})

					label:setLocalZOrder(10)
					label:setTouchEnabled(true):setSwallowTouches(false)
					if isTypeId then
						label.user_data="event:local_itemid_"..tempStr
					else
						label.user_data="event:local_itemname_"..tempStr
					end

					label:addClickEventListener(linktouch)
					if self._outline then
						label:enableOutline(cc.c4b(self._outline[1],self._outline[2],self._outline[3],self._outline[4]), self._outline[5])
					end
					if self._shadowColor then
						label:enableShadow(self._shadowColor, self._shadowOffset, self._blurRadius)
					end

					local element=ccui.RichElementCustomNode:create(index,cc.c3b(0,255,0),255,label)
					self.richlabel:pushBackElement(element)
					index=index+1
				end
			elseif pTagType=="a" then
				local link = pNode.href or ""
				local tempcolor=Dcolor
				if pNode.color then
					tempcolor=pNode.color
				end
				if string.len(tempcolor)==7 then
					table.insert(Tcolor,"0x"..string.sub(tempcolor,2))
				elseif string.len(tempcolor)==6 then
					table.insert(Tcolor,"0x"..tempcolor)
				end

				tag_a=true
				local ccnode = parser[i+1]
				if ccnode and ccnode.type == "content" and ccnode.text then
					local function linktouch(pSender)
						GameUtilSenior.touchlink(pSender,parent,self.richlabel)
					end
					local tempStr=ccnode.text
					tempStr=GameBaseLogic.clearHtmlText(tempStr)
					local tcolor=Dcolor
					if Tcolor[#Tcolor] then tcolor=tonumber(Tcolor[#Tcolor]) or Tcolor end
					local label = GameUtilSenior.newUILabel({
						text = tempStr,
						fontSize = Tsize[#Tsize] or Dsize,
						color = GameBaseLogic.getColor(tcolor),
						position = cc.p(320,110),
					})
					label:setLocalZOrder(10)
					-- label:setTouchEnabled(true)
					-- print("111111111111")
					label.user_data=link
					label:setTouchEnabled(true):addClickEventListener(linktouch)
					-- if pNode.outline and label.enableOutline then
					-- 	local params = string.split(pNode.outline,",")
					-- 	if #params==5 then
					-- 		label:enableOutline(cc.c4b(params[1],params[2],params[3],params[4]), params[5])
					-- 	end
					-- end
					if self._outline then
						label:enableOutline(cc.c4b(self._outline[1],self._outline[2],self._outline[3],self._outline[4]), self._outline[5])
					end
					if self._shadowColor then
						label:enableShadow(self._shadowColor, self._shadowOffset, self._blurRadius)
					end

					label:setSwallowTouches(false)
					if pNode.underline then
						if string.len(pNode.underline)==7 then
							pNode.underline = "0x"..string.sub(pNode.underline,2)
						elseif string.len(pNode.underline)==6 then
							pNode.underline = "0x"..pNode.underline
						end
						GameUtilSenior.addUnderLine(label, GameBaseLogic.getColor4f(tonumber(pNode.underline, 16)), 1)
					end

					local element=ccui.RichElementCustomNode:create(index,cc.c3b(255,255,0),255,label)
					self.richlabel:pushBackElement(element)
					if tempStr == "ui_accept_task" or tempStr == "ui_done_task" then
						local param = {}
						param[1] = tempStr
						param[2] = label
						label:hide():setTouchEnabled(false)
						self.richlabel.param = param
					end
					index=index+1
				end
			elseif pTagType=="effect" then
				if pNode.id then
					local lowSprite = ccui.ImageView:create()
					--lowSprite:loadTexture("common_big_right_gezi.png",ccui.TextureResType.plistType)
					lowSprite:setUnifySizeEnabled(false)
					lowSprite:ignoreContentAdaptWithSize(false)
					lowSprite:setScale9Enabled(true)
					if pNode.width and pNode.height then
						lowSprite:setContentSize(cc.size(pNode.width,pNode.height))
					end
					GameUtilSenior.addEffect(lowSprite,"spriteEffect",4,pNode.id,{x=20,y=pNode.height-15},false,true)
					local element=ccui.RichElementCustomNode:create(index,cc.c3b(0,255,0),255,lowSprite)
					self.richlabel:pushBackElement(element)
					index=index+1
				end
			elseif pTagType=="item" then
				if pNode.icon then
					local info=string.split(pNode.icon,",")
					if #info >1 then
						local itemdef = nil
						--if tonumber(info[1]) then
						--	itemdef = GameSocket:getItemDefByID(info[1])
						--else
						--	itemdef = GameSocket:getItemDefByName(info[1])
						--end
						if tonumber(info[1]) and tonumber(info[2]) then
							local label=ccui.ImageView:create()
							label:loadTexture("common_big_right_gezi.png",ccui.TextureResType.plistType)
							label:setScale9Enabled(true)
							label:setUnifySizeEnabled(false)
							label:ignoreContentAdaptWithSize(false)
							label:setContentSize(cc.size(68,68))
							label:setOpacity(255 * 0.1)
							local param={parent=label, typeId=tonumber(info[1]), num=tonumber(info[2])}
							GUIItem.getItem(param)
							local lowSprite = cc.Sprite:create()
							lowSprite:setPosition(30,30)
							label:addChild(lowSprite)
							local animate = cc.AnimManager:getInstance():getPlistAnimate(4, 65078, 4, 3,false,false,0,function(animate,shouldDownload)
									lowSprite:runAction(cca.repeatForever(animate))
									if shouldDownload==true then
										lowSprite:release()
									end
								end,
								function(animate)
									lowSprite:retain()
								end)
							local element=ccui.RichElementCustomNode:create(index,cc.c3b(0,255,0),255,label)
							self.richlabel:pushBackElement(element)
							index=index+1
						end
					end
				end
				if pNode.src then
					local info=string.split(pNode.src,",")
					if #info >2 then
						local itemdef,c3b = nil,cc.c3b(0,255,0)
						if tonumber(info[1]) then
							itemdef = GameSocket:getItemDefByID(info[1])
						else
							itemdef = GameSocket:getItemDefByName(info[1])
						end

						if itemdef then
							c3b = GameBaseLogic.getItemColor(itemdef.mEquipLevel)
						end
						local function linktouch(pSender)
							GameUtilSenior.touchlink(pSender,parent,self.richlabel)
						end
						
						local label = GameUtilSenior.newUILabel({
							text = info[1],
							fontSize = Tsize[#Tsize],
							anchor = cc.p(1,0.5),
							color = c3b,
							position = cc.p(320,110),
						})
						label:setLocalZOrder(10)
						label:setTouchEnabled(true):setSwallowTouches(false)
						label.user_data="event:local_itemname_"..info[1].."_"..info[2].."_"..info[3]
						label:addClickEventListener(linktouch)
						if self._outline then
							label:enableOutline(cc.c4b(self._outline[1],self._outline[2],self._outline[3],self._outline[4]), self._outline[5])
						end
						if self._shadowColor then
							label:enableShadow(self._shadowColor, self._shadowOffset, self._blurRadius)
						end
						if itemdef then
							GameUtilSenior.addUnderLine(label, GameBaseLogic.getItemColor4f(itemdef.mEquipLevel), 1)
						end
						local element=ccui.RichElementCustomNode:create(index,cc.c3b(0,255,0),255,label)
						self.richlabel:pushBackElement(element)
						index=index+1
					end
				end
			end
		elseif pType=="content" then
			if tag_a then 
				tag_a=false
			else
				local text=pNode.text
				if text then
					local tempStr=GameBaseLogic.clearHtmlText(text)
					local tcolor=Dcolor
					if Tcolor[#Tcolor] then tcolor=tonumber(Tcolor[#Tcolor]) or Tcolor end

					local element
					local toutline = Toutline[#Toutline] or nil
					-- if toutline  and #toutline == 5 then
					if self._outline and #self._outline == 5 then
						element=ccui.RichElementText:create(index,GameBaseLogic.getColor(tcolor),255,tempStr,FONT_NAME,Tsize[#Tsize] or Dsize, cc.c4b(self._outline[1],self._outline[2],self._outline[3],self._outline[4]), self._outline[5])
					else
						element=ccui.RichElementText:create(index,GameBaseLogic.getColor(tcolor),255,tempStr,FONT_NAME,Tsize[#Tsize] or Dsize)
					end

					if self._shadowColor and element.enableShadow then
						element:enableShadow(self._shadowColor, self._shadowOffset, self._blurRadius)
					end

					self.richlabel:pushBackElement(element)
					index=index+1
				end
			end
		elseif pType=="end" then
			if pNode.tag=="font" then
				table.remove(Tcolor,#Tcolor)
				table.remove(Tsize,#Tsize)
				table.remove(Toutline,#Toutline)
			end
			if pNode.tag=="a" then
				table.remove(Tcolor,#Tcolor)
			end
		end
	end
	self.richlabel:formatText()

	local contsize = self.richlabel:getContentSize()
	self:setContentSize(contsize)
	self.richlabel:setPositionX(0)--self.anchor.x*contsize.width)
	self.richlabel:setPositionY(0)--self.anchor.y*contsize.height)
	return contsize
end

function GUIRichLabel:setColor(color)
	self.richlabel:setColor(color)
	return self
end

return GUIRichLabel