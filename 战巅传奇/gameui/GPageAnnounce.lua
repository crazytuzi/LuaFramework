GPageAnnounce = class("GPageAnnounce", function()
    return display.newScene("GPageAnnounce")
end)

function GPageAnnounce:ctor()
	self.xmlPanel=nil
	self.box_annc=nil
	self.btn_Enter=nil
	self.anncList=nil
	self.list_type=nil
	self.updateComplete=false
end

function GPageAnnounce:onEnter()
	self.xmlPanel = GUIAnalysis.load("ui/layout/GPageAnnounce.uif")
	if self.xmlPanel then
		self.box_annc=self.xmlPanel:getChildByName("box_annc")
		self.box_annc:setPosition(cc.p(display.cx,display.cy))
		self.btn_enter=self.box_annc:getChildByName("btn_enter")

		local startNum = 1
		local function startShowBg()
			
			local imgBg = self.xmlPanel:getChildByName("Image_Bg"):align(display.CENTER, display.cx, display.cy)
			asyncload_callback("ui/image/img_welcome_bg_"..startNum..".png", imgBg, function (filepath, texture)
				if GameUtilBase.isObjectExist(imgBg) then
					imgBg:loadTexture(filepath):scale(cc.MAX_SCALE)
				end
			end)

			startNum= startNum+1
			if startNum >=1 then
				startNum =1
			end
		end
		self.box_annc:runAction(cca.repeatForever(cca.seq({cca.delay(0.25),cca.cb(startShowBg)}),tonumber(4)))
		
		-- 公告弹出后 点击进入游戏
		self.btn_enter:addClickEventListener(function (sender)
			self:doLogin()
		end)
		self:addChild(self.xmlPanel)
		self.updateComplete=true
		
		self.box_annc:setVisible(false)

		self:showAnnc()
		-- self:openDoor(self.xmlPanel)
	end
end

function GPageAnnounce:openDoor(ui)
	--我家大门常打开
	local startNum = 1
	local doorNum = 7
	local img_left = ui:getWidgetByName("img_leftdoor")
	local img_right = ui:getWidgetByName("img_rightdoor")

	img_right:setFlippedX(true)
	img_left:setPositionX(display.cx)
	img_right:setPositionX(display.cx)

	local function startOpen()
		asyncload_callback("ui/image/OpenDoor/img_door"..startNum..".jpg", img_left, function (filepath, texture)
			if GameUtilSenior.isObjectExist(img_left) then
				img_left:loadTexture(filepath):scale(display.height/640)
			end
			if GameUtilSenior.isObjectExist(img_right) then
				img_right:loadTexture(filepath):scale(display.height/640)
			end
		end)
		startNum = startNum + 1
		if startNum >= 8 then
			-- img_left:hide()
			-- img_right:hide()
			img_left:runAction(cca.fadeOut(0.5))
			img_right:runAction(cca.fadeOut(0.5))
			self:showAnnc()
		end
	end
	
	ui:runAction(cca.rep(cca.seq({cca.delay(0.25),cca.cb(startOpen)}),tonumber(7)))
end

function GPageAnnounce:showAnnc(  )
	self.box_annc:setVisible(true)
	self:getAnncInfo()
end

function GPageAnnounce:onExit()
	cc.SpriteManager:getInstance():removeFramesByFile("ui/sprite/GPageAnnounce")
	cc.CacheManager:getInstance():releaseUnused(false)
end

function GPageAnnounce:doLogin(args)
	if self.updateComplete then
		self.updateComplete = false
	    
	    asyncload_frames("ui/sprite/GPageServerList",".png",function ()
	        if GameBaseLogic.gameKey and GameBaseLogic.gameKey~="" then
				display.replaceScene(GPageServerList.new())
			else
				display.replaceScene(GPageSignIn.new()) --测试包模拟下登陆流程
			end
	    end)
	else
		--print("正在更新...")
	end
end
-------------------------------------------------
-------       获取平台公告信息      --------------
-------------------------------------------------
function GPageAnnounce:getAnncInfo()
	self.anncList=self.box_annc:getChildByName("list_type")
	self.anncList:setTouchEnabled(true)
	self.anncList:setBounceEnabled(true)
	local scroll_ptinfo=self.box_annc:getChildByName("scroll_annc")
	local fileUtils = cc.FileUtils:getInstance()

	local path=fileUtils:getWritablePath().."annc.json"
	if fileUtils:isFileExist(path) then
		local anncStr=fileUtils:getStringFromFile(path)
		anncStr=string.gsub(anncStr,"\\","")
		local anncTab1=string.split(anncStr,"###")
		GameBaseLogic.annc={}
		for k,v in pairs(anncTab1) do
			local anncTab2=string.split(v,"|||")
			if anncTab2 and #anncTab2>1 then
				local annc={}
				annc["title"]=anncTab2[1]
				annc["type1"]=2  -- 左上角类型[活动，公告，促销]
				annc["type2"]=2  -- 右上角类型[hot，new]
				annc["content"]=anncTab2[2]
				table.insert(GameBaseLogic.annc,annc)
			end
		end
		if not self.list_type then
			local params={
				list=self.anncList,
				layout={repeatY=#anncTab1,repeatX=1,spaceX=0,spaceY=9},
				updateItemfunc=function(item)
					local index=item.index
					item:setTitleText(GameBaseLogic.annc[index]["title"])
					
				end,
				selectItemfunc=function(item)
					--[[
					local child=scroll_ptinfo:getChildByName("rich_annc")
					if child then
						scroll_ptinfo:removeChild(child)
					end
          			local rich_label = GameUtilBase.newRichLabel(cc.size(345,0),5)
					rich_label:setName("rich_annc")
					rich_label:setAnchorPoint(cc.p(0.5,1))
					scroll_ptinfo:addChild(rich_label)
					local anncMsg=item.data["content"]

					GameUtilBase.setRichLabel(rich_label,anncMsg, "", 18,"0xfddfae")
					scroll_ptinfo:setInnerContainerSize(cc.size(345,rich_label:getRealHeight()))

					rich_label:setPosition(cc.p(scroll_ptinfo:getContentSize().width/2,rich_label:getRealHeight()))
					rich_label:setVisible(true)
					]]
					local anncMsg=item.data["content"]
					GPageAnnounce.updateList( scroll_ptinfo,anncMsg )
				end,
				data=GameBaseLogic.annc
			}
			self.list_type=GUIList.new(params)
			self.list_type:setSelectedIndex(1)
			self.anncList:show()
		end
	end
	self.box_annc:show()
end

function GPageAnnounce.updateList( list,strs )
	local t = {}
	if GameUtilSenior.isString(strs) then
		table.insert(t,strs)
	elseif GameUtilSenior.isTable(strs) then
		t = strs
	end
	list:removeAllItems()
	for i,v in ipairs(t) do
		local richLabel = GUIRichLabel.new({size = cc.size(list:getContentSize().width, 30), space=5,name = "hintMsg"..i})
		richLabel:setRichLabel(v,"panel_npctalk",18,"0xfddfae")
		list:pushBackCustomItem(richLabel)
	end
end

return GPageAnnounce
