emailDetailNewDialog=commonDialog:new()

function emailDetailNewDialog:new(layerNum,type,eid,chatSender,chatReport,isAllianceEmail,headlinesData)
    local nc={
		layerNum=layerNum,
		eid=eid,
	    emailType=type,
	    cellHeightTb=nil,
	    showType=nil, --战报详情显示类型
	    chatSender=chatSender,
	}

	--初始化战报
	nc.report=nil
	if chatReport then
		nc.report=chatReport
	else
		nc.report=emailVoApi:getReport(eid)
	end

    setmetatable(nc,self)
    self.__index=self

    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage.plist")
    local JidongbuduiVo = activityVoApi:getActivityVo("jidongbudui")
	if JidongbuduiVo  then
        if G_curPlatName()=="21" or G_curPlatName()=="androidarab" then
          CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/arabTurkeyImage.plist")
        end
        
        if G_curPlatName()=="13" or G_curPlatName()=="androidzhongshouyouko" or G_curPlatName()=="androidzsykonaver" or G_curPlatName()=="androidzsykoolleh" or G_curPlatName()=="androidzsykotstore" then
        CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("koImage/koAcIconImage.plist")

        end

        CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acJidongbudui.plist")
    end
    spriteController:addPlist("public/allianceWar2/allianceWar2.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/iconLevel.plist")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    spriteController:addPlist("public/dailyNews.plist")
    spriteController:addTexture("public/dailyNews.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    
    return nc
end

function emailDetailNewDialog:initTableView()
	if self.panelLineBg then
		self.panelLineBg:setVisible(false)
	end
	if self.panelTopLine then
		self.panelTopLine:setVisible(true)
    	self.panelTopLine:setPositionY(G_VisibleSizeHeight-82)
	end
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.reportDialog,self.reportLayer=nil,nil
    if self.report.type==1 then --战斗报告
		local battleReportDialog=G_requireLua("game/scene/gamedialog/battleReportDialog")
		self.reportDialog=battleReportDialog:new(self.report,self.chatSender)
		self.reportLayer=self.reportDialog:initReportLayer(self.layerNum)
    elseif self.report.type==2 or self.report.type==5 or self.report.type==6 then --2.侦查报告/5.搜索雷达报告/6.间谍卫星报告
		local scoutReportDialog=G_requireLua("game/scene/gamedialog/scoutReportDialog")
		self.reportDialog=scoutReportDialog:new(self.report,self.chatSender)
		self.reportLayer=self.reportDialog:initReportLayer(self.layerNum)
	elseif self.report.type==3 or self.report.type==4 or self.report.type==7 or self.report.type==8 then --3.返回战报/4.采集报告/7.进攻军团城市返回/8.驻防军团城市返回报告
		-- self:showReturnReportDetail() --显示返回战报详情
		local returnReportDialog=G_requireLua("game/scene/gamedialog/returnReportDialog")
		self.reportDialog=returnReportDialog:new(self.report)
		self.reportLayer=self.reportDialog:initReportLayer(self.layerNum)
	end
	if self.reportLayer then
		self.bgLayer:addChild(self.reportLayer)
	end
end

--返回战报的处理
function emailDetailNewDialog:showReturnReportDetail()
	
end

function emailDetailNewDialog:dispose()
	self.layerNum=nil
	self.eid=nil
    self.emailType=nil
    self.cellHeightTb=nil
	self.showType=nil
	if self.reportDialog and self.reportDialog.dispose then
		self.reportDialog:dispose()
		self.reportDialog=nil
		self.reportLayer=nil
	end
	self.report=nil
	self.chatSender=nil
end