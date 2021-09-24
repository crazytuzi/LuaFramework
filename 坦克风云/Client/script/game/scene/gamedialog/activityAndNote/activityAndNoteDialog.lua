--require "luascript/script/componet/commonDialog"
require "luascript/script/game/scene/gamedialog/allianceDialog/allianceFuDialog"
require "luascript/script/game/scene/gamedialog/activityAndNote/acMingjiangpeiyangSmallDialog"
activityAndNoteDialog=commonDialog:new()
function activityAndNoteDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.acNum = nil -- 已经开始的活动的个数
	self.acDailyNum = nil -- 每日活动正在进行中的数量
	self.noteNum = nil
	self.openDialog = nil -- 当前开着的活动面板
	self.noAcTip = nil
	self.noNoteTip = nil
	self.loadingLb = nil --数据加载中，请稍后...
	self.countNum = -1
	self.updateFlag = 0 --限时挑战刷新标记
	self.requestFlag = 0 --限时挑战请求标记
	self.refreshTimeTb = {} --限时挑战刷新label
	self.oldTime = nil --限时挑战10s刷新前置时间
	self.drewNum1 = false
	self.drewNum2 = false
	self.menuItemDesc1=nil
	self.menuItemDesc2=nil
	self.menuItemFlag1 = false
	self.menuItemFlag2 = false
	self.lbTab = nil
	self.dailyLbTab = nil
	self.nhtimeTb=nil --需要特殊处理活动时间显示的
	activityVoApi:addOrRemvoeIcon(1)
	dailyActivityVoApi:formatData()
	dailyActivityVoApi:addOrRemvoeIcon(1)
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage.plist")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/iconGoldImage.plist")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/slotMachine.plist")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/feeImage.plist")
    if base.boss == 1 then
     CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ship/t99999Image.plist")
    end
	local DoorGhostVo = activityVoApi:getActivityVo("doorGhost")
	local ghostWarsVo = activityVoApi:getActivityVo("ghostWars")
	local JidongbuduiVo = activityVoApi:getActivityVo("jidongbudui")
	if JidongbuduiVo or DoorGhostVo then
		if G_curPlatName()=="13" or G_curPlatName()=="androidzhongshouyouko" or G_curPlatName()=="androidzsykonaver" or G_curPlatName()=="androidzsykoolleh" or G_curPlatName()=="androidzsykotstore" then
			CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("koImage/koAcIconImage.plist")
		end
	end
	if DoorGhostVo or ghostWarsVo  then
        if DoorGhostVo then
            if G_curPlatName()=="0" or G_curPlatName()=="21" or G_curPlatName()=="androidarab" then
                CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/arabDoorGhost.plist")
            end
        end
		CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acDoorGhost.plist")
	end
	local SinglesVo = activityVoApi:getActivityVo("singles")
	if SinglesVo  then
		CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acSingles.plist")
	end

	if JidongbuduiVo  then
		if G_curPlatName()=="21" or G_curPlatName()=="androidarab" then
			CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/arabTurkeyImage.plist")
		end
		CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acJidongbudui.plist")
	end
	local BaifudaliVo = activityVoApi:getActivityVo("baifudali")
	local HoldGroundVo = activityVoApi:getActivityVo("holdGround")
	local dayRechargeVo = activityVoApi:getActivityVo("dayRecharge")
	local acDailyRechargeByNewGuiderVo = activityVoApi:getActivityVo("mrcz")
	if BaifudaliVo or HoldGroundVo or dayRechargeVo or acDailyRechargeByNewGuiderVo then
		CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acBaifudali.plist")
	end
	local KuangnuVo = activityVoApi:getActivityVo("kuangnuzhishi")
	if KuangnuVo  then
		CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acKuangnuzhishi.plist")
	end
	
	local zhenqinghuikuiVo = activityVoApi:getActivityVo("zhenqinghuikui")
	if zhenqinghuikuiVo then
		CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acZhenqinghuikui.plist")
		CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/jingDongCard.plist")
	end
	
	local ShengdanbaozangVo = activityVoApi:getActivityVo("shengdanbaozang")
	if ShengdanbaozangVo then
		CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acShengdanbaozang.plist")
		if(G_isArab() or G_curPlatName()=="0")then
			CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("arImage/acMysteriousArms_ar.plist")
		end
		CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acMysteriousArms.plist")
	end
    
	local ShengdankuanghuanVo = activityVoApi:getActivityVo("shengdankuanghuan")
	if ShengdankuanghuanVo then
		CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acShengdankuanghuan.plist")
		CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acArsenalImage.plist")
	end
	local yuandanxianliVo = activityVoApi:getActivityVo("yuandanxianli")
	local HoldGroundVo = activityVoApi:getActivityVo("holdGround")
	local sendGeneralVo = activityVoApi:getActivityVo("songjiangling")
	local all = activityVoApi:getAllActivity()
	local luckcardFlag=false
	for k,v in pairs(all) do
		local arr=Split(v.type,"_")
		if arr[1]=="luckcard" then
			luckcardFlag=true
			break
		end
	end
	if yuandanxianliVo  or zhenqinghuikuiVo or HoldGroundVo or sendGeneralVo or luckcardFlag then
		CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acYuanDanXianLi.plist")
	end
	local yrjVo = activityVoApi:getActivityVo("yrj")
	if yrjVo then
		spriteController:addPlist("public/acYrjImage.plist")
    	spriteController:addPlist("public/yrjV2.plist")
	    spriteController:addTexture("public/acYrjImage.png")
    	spriteController:addTexture("public/yrjV2.png")
	end

	local tankjianianhuaVo = activityVoApi:getActivityVo("tankjianianhua")
	if tankjianianhuaVo then
		CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acTankjianianhua.plist")
	end
	
	local xuyuanluVo = activityVoApi:getActivityVo("xuyuanlu")
	if xuyuanluVo then
		CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acXuyuanlu.plist")
	end
	local xinchunhongbaoVo = activityVoApi:getActivityVo("xinchunhongbao")
	if xinchunhongbaoVo then
        if G_curPlatName()=="0" or G_curPlatName()=="21" or G_curPlatName()=="androidarab" then
          CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/arabXinchunhongbao.plist")
        end
		CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acXinchunhongbao.plist")
	end

	local equipSearchIIVo = activityVoApi:getActivityVo("equipSearchII")   
	if equipSearchIIVo then   
		if equipSearchIIVo.version and (equipSearchIIVo.version==4 or equipSearchIIVo.version==5) then    
			CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acKafukabaozang.plist")   
		end   
	end
	local baifudaliVo = activityVoApi:getActivityVo("baifudali")
	if baifudaliVo then
		if G_curPlatName() =="11" or G_curPlatName() =="androidsevenga" then
			CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/sevenIcon.plist")
		end
	end
	local mayDayVo = activityVoApi:getActivityVo("xingyunzhuanpan")
	if mayDayVo then
		CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acMayDayImage.plist")
		CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acMayDaySupply.plist")
	end
	local banzhangshilianVo = activityVoApi:getActivityVo("banzhangshilian")
	if banzhangshilianVo then
		CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("allianceWar/warMap.plist")
	end
	local kafkaGiftVo = activityVoApi:getActivityVo("kafkagift")
	local acChongzhisongliVo = activityVoApi:getActivityVo("chongzhisongli")
	local acDanrichongzhiVo = activityVoApi:getActivityVo("danrichongzhi")
	
	local acDanrixiaofeiVo = activityVoApi:getActivityVo("danrixiaofei")
	local xiaofeisongliVo = activityVoApi:getActivityVo("xiaofeisongli")
	local acThanksGivingVo = activityVoApi:getActivityVo("ganenjiehuikui")
	local acGeneralRecallVo = activityVoApi:getActivityVo("djrecall")
	if kafkaGiftVo or acChongzhisongliVo or acDanrichongzhiVo or acDanrixiaofeiVo  or xiaofeisongliVo or acThanksGivingVo or acGeneralRecallVo  then
		spriteController:addTexture("public/acKafkaGift.pvr.ccz")
		spriteController:addPlist("public/acKafkaGift.plist")
	end
	local acHaoshichengshuangVo = activityVoApi:getActivityVo("haoshichengshuang")
	if acHaoshichengshuangVo then
		CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acHaoshichengshuang.plist")
	end
	local swchallengeactiveVo = activityVoApi:getActivityVo("swchallengeactive")
	local jffpVo = activityVoApi:getActivityVo("jffp")
	if swchallengeactiveVo or jffpVo then
		CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/superWeapon/swChallenge.plist")
	end

	local acXingyunpindianVo = activityVoApi:getActivityVo("xingyunpindian")
	local acRepublicHuiVo = activityVoApi:getActivityVo("republicHui")
	local acGqkhVo = activityVoApi:getActivityVo("gqkh")
	local acChristmasAttireVo=activityVoApi:getActivityVo("christmas2016")
	if acXingyunpindianVo or acRepublicHuiVo or acGqkhVo or acChristmasAttireVo then
		CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acRepublicHui.plist")
	end
    if acChristmasAttireVo then
	    spriteController:addPlist("public/acChrisEveImage.plist")
    	spriteController:addTexture("public/acChrisEveImage.png")
	    spriteController:addPlist("public/acChristmas2016_images.plist")
    	spriteController:addTexture("public/acChristmas2016_images.png")
    end

	local acFirstRechargenewVo = activityVoApi:getActivityVo("firstRechargenew")
	local acFightRanknewVo = activityVoApi:getActivityVo("fightRanknew")
	local acChallengeranknewVo = activityVoApi:getActivityVo("challengeranknew")
	local acChrisEvVo = activityVoApi:getActivityVo("shengdanqianxi")
    local acLuckyCatVo = activityVoApi:getActivityVo("xinfulaba")
	local acChristmasFightVo = activityVoApi:getActivityVo("christmasfight")
    local acMingjiangzailinVo = activityVoApi:getActivityVo("mingjiangzailin")
    local acSweetTroubleVo=activityVoApi:getActivityVo("halloween")
    local acNewYearVo = activityVoApi:getActivityVo("newyeargift")
    local acChunjiepanshengVo = activityVoApi:getActivityVo("chunjiepansheng")
	local acNewYearsEveVo = activityVoApi:getActivityVo("newyeareva")
	local acRechargeGameVo = activityVoApi:getActivityVo("rechargeCompetition")
	local acRechargeBagVo = activityVoApi:getActivityVo("rechargebag")
	local acBenfuqianxianVo = activityVoApi:getActivityVo("benfuqianxian")
 	local acOlympicCollectVo=activityVoApi:getActivityVo("aoyunjizhang")
	local acMidAutumnVo=activityVoApi:getActivityVo("midautumn")
	local acThreeYearVo=activityVoApi:getActivityVo("threeyear")
	local acMineExploreVo=activityVoApi:getActivityVo("mineExplore")
	local acMineExploreGVo = activityVoApi:getActivityVo("mineExploreG")
	local acCjyxVo=activityVoApi:getActivityVo("cjyx")
	if acCjyxVo then
	    spriteController:addPlist("public/acChrisEveImage.plist")
    	spriteController:addTexture("public/acChrisEveImage.png")
    	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acWanshengjiedazuozhan2.plist")
	end
	if acThreeYearVo or acGeneralRecallVo then
	    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	    spriteController:addPlist("public/acthreeyear_images.plist")
    	spriteController:addTexture("public/acthreeyear_images.png")
	    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	end
	if acGeneralRecallVo then
		CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/platWar/platWarImage.plist")
	end
    if acOlympicCollectVo then
        if G_curPlatName()=="59" or G_curPlatName()=="13" or G_curPlatName()=="androidzhongshouyouko" or G_curPlatName()=="androidzsykonaver" or G_curPlatName()=="androidzsykoolleh" or G_curPlatName()=="androidzsykotstore" or G_isKakao()==true or G_curPlatName()=="androidcmge" then
	  		spriteController:addPlist("public/olympic_icon_korea.plist")
    		spriteController:addTexture("public/olympic_icon_korea.png")
        end
    	spriteController:addPlist("public/acOlympicImage.plist")
    	spriteController:addTexture("public/acOlympicImage.png")
    end
    if acMidAutumnVo then
	    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	    spriteController:addPlist("public/acmidautumn_images.plist")
	    spriteController:addTexture("public/acmidautumn_images.png")
	    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    end
    if acMineExploreVo or acMineExploreGVo then
	    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	    spriteController:addPlist("public/acMineExplore_images.plist")
	    spriteController:addTexture("public/acMineExplore_images.png")
	    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    end
    if acChunjiepanshengVo then
    	local version = acChunjiepanshengVoApi:getVersion()
    	if version and version==3 then
    		spriteController:addPlist("public/acChunjiepansheng"..version..".plist")
			spriteController:addTexture("public/acChunjiepansheng"..version..".png")
    	else
			spriteController:addPlist("public/acChunjiepansheng.plist")
			spriteController:addTexture("public/acChunjiepansheng.png")
		end
		if version and version==4 then
			spriteController:addPlist("public/acChunjiepansheng4.plist")
			spriteController:addTexture("public/acChunjiepansheng4.png")
		end
    end
    if acRechargeBagVo then
	    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
		spriteController:addPlist("public/acRechargeBag_images.plist")
		spriteController:addTexture("public/acRechargeBag_images.png")
		spriteController:addPlist("public/acNewYearsEva.plist")
    	spriteController:addTexture("public/acNewYearsEva.png")
      	spriteController:addPlist("public/dimensionalWar/dimensionalWar.plist")
        spriteController:addTexture("public/dimensionalWar/dimensionalWar.png")
	    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    end
    if(acNewYearsEveVo) or acRechargeBagVo or acBenfuqianxianVo then
		spriteController:addPlist("public/acChunjiepansheng.plist")
		spriteController:addTexture("public/acChunjiepansheng.png")
	end

	if acBenfuqianxianVo then
		CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
		spriteController:addPlist("public/acNewYearsEva.plist")
    	spriteController:addTexture("public/acNewYearsEva.png")
	    spriteController:addPlist("public/acRadar_images.plist")
	    spriteController:addTexture("public/acRadar_images.png")
	    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	end

    local acImminentVo = activityVoApi:getActivityVo("yichujifa")
    local acFeixutansuoVo = activityVoApi:getActivityVo("feixutansuo")
    local acDouble11Vo = activityVoApi:getActivityVo("double11")
    local acDouble11NewVo = activityVoApi:getActivityVo("double11new")
	if acImminentVo or acChrisEvVo or acFirstRechargenewVo or acFightRanknewVo or acChallengeranknewVo or acLuckyCatVo or acSweetTroubleVo or acMingjiangzailinVo or acChristmasFightVo or acNewYearVo or acChunjiepanshengVo or acRechargeGameVo or acFeixutansuoVo or acBenfuqianxianVo or acOlympicCollectVo or acMidAutumnVo or acDouble11Vo or acDouble11NewVo then
        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
		CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acFirstRechargenew.plist")
        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	end
	
	local acThanksGivingVo=activityVoApi:getActivityVo("ganenjiehuikui")
	local acNewYearVo=activityVoApi:getActivityVo("newyeargift")
	local acChrisEvVo = activityVoApi:getActivityVo("shengdanqianxi")
	local acAnniversaryVo = activityVoApi:getActivityVo("anniversary")
	local acStormFortressVo = activityVoApi:getActivityVo("stormFortress")
	-- if acStormFortressVo then
 --    	spriteController:addPlist("public/acStormFortressImage/acStormFortressImage.plist")--stormFortressBg1.jpg stormFortressBg2.jpg
	-- 	spriteController:addTexture("public/acStormFortressImage/acStormFortressImage.png")
	-- end
	local allVo=activityVoApi:getAllActivity()
	local pjjnhFlag=false
	for k,v in pairs(allVo) do
		local arr=Split(v.type,"_")
		if arr[1]=="pjjnh" then
			pjjnhFlag=true
			break
		end
	end
	if acDouble11Vo or acDouble11NewVo or acChrisEvVo or acThanksGivingVo or acNewYearVo or acChunjiepanshengVo or acNewYearVo or acAnniversaryVo or pjjnhFlag or acOlympicCollectVo or acMidAutumnVo or acChristmasAttireVo then
		CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/bubbleImage.plist")
    end
    if (acDouble11Vo and acDouble11Vo.version and acDouble11Vo.version==2) or (acDouble11NewVo and acDouble11NewVo.version and acDouble11NewVo.version ==2) then
    	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
		CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acCnNewYearImage/acCnNewYearImage.plist")--
		CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acWanshengjiedazuozhan2.plist")
        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    end
    	
	local acWanshengjiedazuozhanVo = activityVoApi:getActivityVo("wanshengjiedazuozhan")
	if acWanshengjiedazuozhanVo then
		local version=acWanshengjiedazuozhanVo.version
		if version and version>1 then
			CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acWanshengjiedazuozhan"..version..".plist")
		else
			CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acWanshengjiedazuozhan.plist")
		end
	end

	local acGej2016Vo = activityVoApi:getActivityVo("gej2016")
	if acGej2016Vo then
		spriteController:addPlist("public/acGej2016Image.plist")
	    spriteController:addTexture("public/acGej2016Image.png")
	end

	local acWsjdzzVo = activityVoApi:getActivityVo("wsjdzz")
	local acWsjdzzIIVo = activityVoApi:getActivityVo("wsjdzz2017")
	if acWsjdzzVo or acWsjdzzIIVo then
	if acWsjdzzVo then
			CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acWanshengjiedazuozhan.plist")			
		end
		CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/platWar/platWarImage.plist")
        spriteController:addPlist("public/taskYouhua.plist")
        spriteController:addTexture("public/taskYouhua.png")
	end
	if acWsjdzzIIVo then
		CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acWsjdzzIIImage.plist")
        spriteController:addPlist("public/wsjdzzV3.plist")
        spriteController:addTexture("public/wsjdzzV3.png")
	end

	local acTankBattleVo = activityVoApi:getActivityVo("tankbattle")
	if acTankBattleVo then
		CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acTankBattle.plist")
	end

	local acOpenyearVo = activityVoApi:getActivityVo("openyear")
	if acOpenyearVo then
		CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/platWar/platWarImage.plist")
		local function addPlist()
	        spriteController:addPlist("public/acOpenyearImage.plist")
	        spriteController:addTexture("public/acOpenyearImage.png")
	    end
	    G_addResource8888(addPlist)
	end
	local acBtzxVo = activityVoApi:getActivityVo("btzx")
	if acBtzxVo then
		spriteController:addPlist("public/acBtzxImage.plist")
	    spriteController:addTexture("public/acBtzxImage.png")
	end

	local acGqkhVo = activityVoApi:getActivityVo("gqkh")
	if acGqkhVo then
		spriteController:addPlist("public/acGqkh.plist")
	    spriteController:addTexture("public/acGqkh.png")
	    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/bubbleImage.plist")
		CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
        CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/platWar/platWarImage.plist")
        CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acCnNewYearImage/acCnNewYearImage.plist")
        CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acFirstRechargenew.plist")
        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	end
	
	if acChristmasFightVo or acNewYearsEveVo or acStormFortressVo then
		CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	    spriteController:addPlist("public/acChrisEveImage.plist")
    	spriteController:addTexture("public/acChrisEveImage.png")
        CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/platWar/platWarImage.plist")
        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	end

	if acChrisEvVo or acChunjiepanshengVo or acBenfuqianxianVo then
		CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	    spriteController:addPlist("public/acChrisEveImage.plist")
    	spriteController:addTexture("public/acChrisEveImage.png")
		CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	end
	if(acChrisEvVo)then
		spriteController:addPlist("public/acChrisEveImage2.plist")
        spriteController:addTexture("public/acChrisEveImage2.png")
    end

	if acNewYearsEveVo or acStormFortressVo then
		CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
     	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ship/t99998Image.plist")
    	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acWanshengjiedazuozhan2.plist")
    	spriteController:addPlist("public/acNewYearsEva.plist")
    	spriteController:addTexture("public/acNewYearsEva.png")
    	spriteController:addPlist("public/acLuckyCat.plist")
    	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	end

	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acItemBg.plist")
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	local acImminentVo = activityVoApi:getActivityVo("yichujifa")
	local acNewYearVo = activityVoApi:getActivityVo("newyeargift")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage2.plist")
	if acImminentVo or acNewYearVo then
		spriteController:addPlist("serverWar/serverWar.plist")
		spriteController:addTexture("serverWar/serverWar.pvr.ccz")
		CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
        CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acImminentImage/acImminentImage.plist")
        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
     end
	local acAnniversaryBlessVo = activityVoApi:getActivityVo("anniversaryBless")
	local acBlessingWheelVo = activityVoApi:getActivityVo("blessingWheel")
	local all = activityVoApi:getAllActivity()
	local luckcardFlag=false
	local olympicFlag = false
	local jblbFlag = false
	for k,v in pairs(all) do
		local arr=Split(v.type,"_")
		if arr[1]=="luckcard" then
			luckcardFlag=true
		elseif arr[1] =="olympic" then
			olympicFlag =true
		elseif arr[1] == "jblb" then
			jblbFlag = true
		end
	end
    if acAnniversaryBlessVo or acBlessingWheelVo or luckcardFlag or olympicFlag then
	    spriteController:addPlist("public/acBlessWords.plist")
    	spriteController:addTexture("public/acBlessWords.png")
    end

    if olympicFlag then
        if G_curPlatName()=="59" or G_curPlatName()=="13" or G_curPlatName()=="androidzhongshouyouko" or G_curPlatName()=="androidzsykonaver" or G_curPlatName()=="androidzsykoolleh" or G_curPlatName()=="androidzsykotstore" or G_isKakao()==true or G_curPlatName()=="androidcmge" then
	  		spriteController:addPlist("public/olympic_icon_korea.plist")
    		spriteController:addTexture("public/olympic_icon_korea.png")
        end
    	spriteController:addPlist("public/acOlympicImage.plist")
    	spriteController:addTexture("public/acOlympicImage.png")
    end

    local acMonthlySignVo=activityVoApi:getActivityVo("monthlysign")
    if(acMonthlySignVo)then
    	spriteController:addPlist("public/acMonthlySign.plist")
    	spriteController:addTexture("public/acMonthlySign.png")
    end
    local acAntiAirVo=activityVoApi:getActivityVo("battleplane")
    if(acAntiAirVo)then
		spriteController:addPlist("public/acAntiAir.plist")
		spriteController:addTexture("public/acAntiAir.png")
    end    
    local acSdzsVo=activityVoApi:getActivityVo("sdzs")
    if acSdzsVo then
    	spriteController:addPlist("public/serverWarLocal/serverWarLocalCommon.plist")
    	spriteController:addTexture("public/serverWarLocal/serverWarLocalCommon.png")
    end

    local acFyssVo = activityVoApi:getActivityVo("fuyunshuangshou")
	if acFyssVo then
		local function addPlist()
	        spriteController:addPlist("public/acOpenyearImage.plist")
	        spriteController:addTexture("public/acOpenyearImage.png")
	    end
	    G_addResource8888(addPlist)
	end

	local acZnkhVo = activityVoApi:getActivityVo("znkh")
	if acZnkhVo then
		local function addPlist()
			spriteController:addPlist("public/acZnkhImage.plist")
		    spriteController:addTexture("public/acZnkhImage.png")
	    end
	    G_addResource8888(addPlist)
	end
	local acSmbdVo = activityVoApi:getActivityVo("smbd")
	
	if acSmbdVo then
		spriteController:addPlist("public/smbdPic.plist")
    	spriteController:addTexture("public/smbdPic.png")
	end

	local acLmqrjVo = activityVoApi:getActivityVo("lmqrj")
	if acLmqrjVo then
		spriteController:addPlist("public/acLmqrjImage.plist")
	    spriteController:addTexture("public/acLmqrjImage.png")
	    if acLmqrjVoApi and acLmqrjVoApi:getVersion()==2 then
	    	spriteController:addPlist("public/acLmqrjImage2.plist")
	    	spriteController:addTexture("public/acLmqrjImage2.png")
	    end
	end

	local acThfbVo = activityVoApi:getActivityVo("thfb")
	local acNewDoubleOneVo = activityVoApi:getActivityVo("new112018")
	if acThfbVo or acNewDoubleOneVo then
		spriteController:addPlist("public/acThfb.plist")
		spriteController:addTexture("public/acThfb.png")
	end
	if acThfbVo then
		-- 加载资源
		spriteController:addPlist("public/packsImage.plist")
		
		spriteController:addPlist("public/taskYouhua.plist")
    	spriteController:addTexture("public/taskYouhua.png")
	    spriteController:addTexture("public/packsImage.png")
	    
	    spriteController:addPlist("public/acDouble11_NewImage.plist")
		spriteController:addTexture("public/acDouble11_NewImage.png")
	end

	local acMjzyVo = activityVoApi:getActivityVo("mjzy")
	if acMjzyVo then

		CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888) 
		spriteController:addPlist("public/taskYouhua.plist")
	    spriteController:addTexture("public/taskYouhua.png")
	    spriteController:addPlist("public/acmjzy.plist")
	   	spriteController:addTexture("public/acmjzy.png")
	   	spriteController:addPlist("public/acMjzxImage.plist")
		spriteController:addTexture("public/acMjzxImage.png")
		spriteController:addPlist("public/youhuaUI4.plist")
    	spriteController:addTexture("public/youhuaUI4.png")
		CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

	end

	local acXlysVo = activityVoApi:getActivityVo("xlys")
	if acXlysVo then
		spriteController:addPlist("public/acXlys.plist")
		spriteController:addTexture("public/acXlys.png")
	end

	if jblbFlag then
		G_addResource8888(function()
			spriteController:addPlist("public/acCustomImage.plist")
	        spriteController:addTexture("public/acCustomImage.png")
	    end)
	end

	local acXJlbVo = activityVoApi:getActivityVo("xjlb")
	if acXJlbVo then
		G_addResource8888(function()
	    	spriteController:addPlist("public/acXjlbImages.plist")
	        spriteController:addTexture("public/acXjlbImages.png")
	    end)
	end

	return nc
end

function activityAndNoteDialog:resetTab()
    self:setTopLineShow()

	local index=0
	for k,v in pairs(self.allTabs) do
		local  tabBtnItem=v
		if index==0 then
			print("activityAndNoteDialog:resetTab: ", index, activityVoApi.newNum)
			if activityVoApi.newNum >0 then
				self:setTipsVisibleByIdx(true,1,activityVoApi.newNum)
			else
				self:setTipsVisibleByIdx(false,1)
			end 
			tabBtnItem:setPosition(119,G_VisibleSizeHeight - tabBtnItem:getContentSize().height/2-81)
		elseif index==1 then
			if base.dailyAcYouhuaSwitch==1 then
				local drNum=dailyActivityVoApi:canRewardNum()
				if drNum>0 then
					self:setTipsVisibleByIdx(true,2,drNum)
				else
					self:setTipsVisibleByIdx(false,2)
				end 
			end
			tabBtnItem:setPosition(320,G_VisibleSizeHeight-tabBtnItem:getContentSize().height/2-81)
		elseif index==2 then
			print("activityAndNoteDialog:resetTab: ", index, noteVoApi.newNum)
			if platCfg.platLanguageNote[G_curPlatName()]~=nil then
				if self.newsIcon==nil then
					local capInSet1 = CCRect(17, 17, 1, 1)
					local function touchClick()
					end
					self.newsIcon =LuaCCScale9Sprite:createWithSpriteFrameName("NumBg.png",capInSet1,touchClick)
					self.newsIcon:ignoreAnchorPointForPosition(false)
					self.newsIcon:setAnchorPoint(CCPointMake(0.5,0.5))
					self.newsIcon:setPosition(ccp(G_VisibleSizeWidth-35,G_VisibleSizeHeight-95))
					self.bgLayer:addChild(self.newsIcon,6)
					self.newsIcon:setScale(0.7)
				end
				if noteVoApi.newNum >0 then
					self.newsIcon:setVisible(true)
				else
					self.newsIcon:setVisible(false)
				end 
			else
				if noteVoApi.newNum >0 then
					self:setTipsVisibleByIdx(true,3,noteVoApi.newNum)
				else
					self:setTipsVisibleByIdx(false,3)
				end 
			end
			tabBtnItem:setPosition(521,G_VisibleSizeHeight-tabBtnItem:getContentSize().height/2-81)
		end
		if index==self.selectedTabIndex then
			tabBtnItem:setEnabled(false)
		end 
		index=index+1
	end
	local function refreshListener(event,data)
		self:eventListner(event,data)
	end
	self.refreshListener=refreshListener
	eventDispatcher:addEventListener("activity.dialog.refresh",refreshListener)
end

-- 更新显示新活动和新公告的个数
function activityAndNoteDialog:updateNewNum()
	if self.selectedTabIndex == 0 then -- 活动
		if activityVoApi.newNum and activityVoApi.newNum >0 then
			self:setTipsVisibleByIdx(true,1,activityVoApi.newNum)
		else
			self:setTipsVisibleByIdx(false,1)
		end 
	elseif self.selectedTabIndex ==1 then
	elseif self.selectedTabIndex == 2 then -- 公告
		if platCfg.platLanguageNote[G_curPlatName()]~=nil then
			if self.newsIcon==nil then
				local capInSet1 = CCRect(17, 17, 1, 1)
				local function touchClick()
				end
				self.newsIcon =LuaCCScale9Sprite:createWithSpriteFrameName("NumBg.png",capInSet1,touchClick)
				self.newsIcon:ignoreAnchorPointForPosition(false)
				self.newsIcon:setAnchorPoint(CCPointMake(0.5,0.5))
				self.newsIcon:setPosition(ccp(G_VisibleSizeWidth-40,G_VisibleSizeHeight-100))
				self.bgLayer:addChild(self.newsIcon,6)
				self.newsIcon:setScale(0.5)
			end
			if noteVoApi.newNum >0 then
				self.newsIcon:setVisible(true)
			else
				self.newsIcon:setVisible(false)
			end
		else
			if noteVoApi.newNum >0 then
				self:setTipsVisibleByIdx(true,3,noteVoApi.newNum)
			else
				self:setTipsVisibleByIdx(false,3)
			end
		end
	end
end

function activityAndNoteDialog:getDataByType(type)
	if self.tv then
		self.tv:setPosition(ccp(10000,0))
	end
	if type==nil then
		type=1
	end
	if type==1 then
		if activityVoApi.init == false then
			if self.loadingLb then
				self.loadingLb:setString(getlocal("loadingDesc"))
				self.loadingLb:setVisible(true)
			end
			self.countNum=0
			local function getList(fn,data)
				local ret,sData=base:checkServerData(data)
				if ret==true then
					PlayEffect(audioCfg.mouseClick)
					if sData.data.activelist ~= nil then
						activityVoApi:formatActivityListData(sData.data.activelist)
						dailyActivityVoApi:formatActivityListData(sData.data.activelist)
						if self.loadingLb then
							self.loadingLb:setVisible(false)
						end
						self.countNum=-1
						self.lbTab={}
						self.nhtimeTb={}
						self.tv:setPosition(ccp(25,40))
						self.tv:reloadData()
						self:doUserHandler()
					end
				end
			end
			socketHelper:getActivityList(getList)
		else
			if self.loadingLb then
				self.loadingLb:setVisible(false)
			end
			self.countNum=-1
			self.lbTab={}
			self.nhtimeTb={}
			self.tv:setPosition(ccp(25,40))
			self.tv:reloadData()
			self:doUserHandler()
		end
	elseif type==2 then
		dailyActivityVoApi:formatData()
		self.dailyLbTab={}
		self.tv:setPosition(ccp(25,40))
		self.tv:reloadData()
		self:doUserHandler()
	elseif type==3 then
		if noteVoApi.init == true then
			if self.loadingLb then
				self.loadingLb:setVisible(false)
			end
			self.countNum=-1
			self.tv:setPosition(ccp(25,40))
			self.tv:reloadData()
			self:doUserHandler()
		else
			if self.loadingLb then
				self.loadingLb:setString(getlocal("loadingDesc"))
				self.loadingLb:setVisible(true)
			end
			self.countNum=0
			local  function initNoteData(fn,data)
				local ret,sData=base:checkServerData(data)
				if ret==true then
					if sData.data.notices ~= nil then
						if(self and self.tv)then
							noteVoApi:formatData(sData.data.notices)
							if self.loadingLb then
								self.loadingLb:setVisible(false)
							end
							self.countNum=-1
							self.tv:setPosition(ccp(25,40))
							self.tv:reloadData()
							self:doUserHandler()
						end
					end
				end
			end
			socketHelper:getNoteList(initNoteData)
		end
	end
end


--点击tab页签 idx:索引
function activityAndNoteDialog:initTableView()
	local function callBack(...)
		return self:eventHandler(...)
	end
	local hd= LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth - 50,G_VisibleSizeHeight-210),nil)
	self.tv:setAnchorPoint(ccp(0,0))
	self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
	self.bgLayer:addChild(self.tv)
	self.tv:setPosition(ccp(25,40))
	self.tv:setMaxDisToBottomOrTop(120)
  
	self.loadingLb=GetTTFLabelWrap(getlocal("loadingDesc"),30,CCSizeMake(self.bgLayer:getContentSize().width-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	self.loadingLb:setAnchorPoint(ccp(0.5,1.5))
	self.loadingLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-30))
	self.loadingLb:setColor(G_ColorWhite)
	self.bgLayer:addChild(self.loadingLb)
	self.loadingLb:setVisible(false)
end

function activityAndNoteDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		if self.selectedTabIndex == 0 then
			if activityVoApi.init == true then
				local acLen = SizeOfTable(activityVoApi:getAllActivity())
				if acLen > 0 then

					return acLen
				end
			end
			return 0
		elseif self.selectedTabIndex == 1 then
			return dailyActivityVoApi:getActivityNum()
		elseif self.selectedTabIndex == 2 then
			if noteVoApi.init == true then
				local noteLen = SizeOfTable(noteVoApi:getAllNote())
				if noteLen > 0 then
					return noteLen
				end
			end
			return 0
		end
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize=CCSizeMake(G_VisibleSizeWidth - 50,140)
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		local bgH = 136 -- 背景框的高度
		local labelX = 130 --文本的X坐标
		if G_getCurChoseLanguage() =="ar" then
			labelX = 40
		end
		-- 信息条背景
		local function cellClick(hd,fn,index)
			if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
				if G_checkClickEnable()==false then
		            do
		                return
		            end
		        else
		            base.setWaitTime=G_getCurDeviceMillTime()
		        end
		        PlayEffect(audioCfg.mouseClick)
			self:openInfo(idx)
		end
		end

		local backSprie  
		local backSpriteCenterY
		local function touch(tag,object)
			if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
				if G_checkClickEnable()==false then
		            do
		                return
		            end
		        else
		            base.setWaitTime=G_getCurDeviceMillTime()
		        end
		        PlayEffect(audioCfg.mouseClick)
				if self.selectedTabIndex==1 then
					dailyActivityVoApi:sortActivity()
					local acVo=dailyActivityVoApi:getAllActivity()[tag + 1]
					local tabStr={}
					local colorTab={}
					if acVo and acVo.type then
						if acVo.type=="rpShop" then
							local str=getlocal("dailyActivity_rpshop_desc")
							tabStr={" ",str," "}
						elseif acVo.type=="boss" then
							local str=getlocal("dailyActivity_boss_desc")
							tabStr={" ",str," "}
						elseif acVo.type=="ttjj" then
							local str=getlocal("dailyActivity_ttjj_infoDesc")
							tabStr={" ",str," "}
						elseif acVo.type=="xstz" then
							local str=getlocal("limitChanllengeNI")
							tabStr={" ",str," "}
						elseif acVo.type=="xstzh" then
							local str=getlocal("limitChanllengeHI")
							tabStr={" ",str," "}
						elseif acVo.type == "ydhk" then
							local gems=50
							if dailyYdhkVoApi then
								local cfg=dailyYdhkVoApi:getCfg()
								gems=cfg.goldDayLimit
							end
							local str=getlocal("daily_ydhk_I",{gems})
							tabStr={" ",str," "}
						elseif acVo.type=="dailychoice" then
							local str=getlocal("dailyActivity_dailyAnswer_desc")
							tabStr={" ",str," "}
						elseif acVo.type=="drew1" or acVo.type=="drew2" then
							if acVo.type=="drew1" and receivereward1VoApi:checkShopOpen()==2 then
			self:openInfo(tag)
							elseif acVo.type=="drew2" and receivereward2VoApi:checkShopOpen()==2 then
								self:openInfo(tag)
							else
								local str=getlocal("dailyActivity_receivereward_desc")
								local moPrivilegeFlag, moPrivilegeValue
								if militaryOrdersVoApi then
									moPrivilegeFlag, moPrivilegeValue = militaryOrdersVoApi:isUnlockByPrivilegeId(4)
								end
								if moPrivilegeFlag == true and moPrivilegeValue then
									str = getlocal("dailyActivity_receivereward_desc1", {10 * moPrivilegeValue})
								end
								tabStr={" ",str," "}
		end
						elseif acVo.type=="dailyLottery" then
							local str=getlocal("dailyActivity_lottery_desc")
							tabStr={" ",str," "}
						elseif acVo.type=="isSignSwitch" then
							local str=getlocal("dailyActivity_sign_desc")
							tabStr={" ",str," "}
						elseif acVo.type=="dnews" then
							local str=getlocal("dailyNews_description")
							tabStr={" ",str," "}
						else
							self:openInfo(tag)
						end
					end
					if tabStr and SizeOfTable(tabStr)>0 then
						local td=smallDialog:new()
				        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28,colorTab)
				        sceneGame:addChild(dialog,self.layerNum+1)
				    end
				else
					self:openInfo(tag)
				end
			end
		end
		local menuItemDesc
		if self.selectedTabIndex==0 and base.dailyAcYouhuaSwitch==1 then
			menuItemDesc=GetButtonItem("yh_IconReturnBtn.png","yh_IconReturnBtn_Down.png","yh_IconReturnBtn_Down.png",touch,idx,nil,0)
		else
			menuItemDesc=GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",touch,idx,nil,0)
		end
		local menuDesc=CCMenu:createWithItem(menuItemDesc)
		menuDesc:setTouchPriority(-(self.layerNum-1)*20-3)
		menuItemDesc:setAnchorPoint(ccp(1,0.5))
		local acIconUrl -- todo 获取活动和新闻的图标
		local addIcon,addIcon2 = nil,nil
		local isNew = false
		local addFlicker = false
		if self.selectedTabIndex==0 then -- 活动
			local acVo=activityVoApi:getAllActivity()[idx + 1]
			local arr=Split(acVo.type,"_")
			if arr[1] == "jblb" or acVo.type == "xjlb" then
				local bsColor, bsTouchColor, bgImage
				if acVo.type == "xjlb" then
					bsColor, bsTouchColor = acCashGiftBagVoApi:getThemeColor()
					bgImage = "acxjlb_activeListBg.png"
				else
					bsColor, bsTouchColor = acCustomVoApi:getThemeColor(arr[2])
					bgImage = "acci_activeListBg.png"
				end
				backSprie=GetButtonItem(bgImage,bgImage,bgImage,cellClick,idx,nil,nil,nil,nil,nil,nil,nil,nil,nil,{bsColor, bsTouchColor})
				local bgMenu=CCMenu:createWithItem(backSprie)
				bgMenu:setTouchPriority(-(self.layerNum-1)*20-2)
				cell:addChild(bgMenu,1)
				backSpriteCenterY=backSprie:getContentSize().height/2
				bgMenu:setPosition(ccp(backSprie:getContentSize().width/2,backSpriteCenterY))
				menuDesc:setPosition(ccp(backSprie:getContentSize().width - 30, backSpriteCenterY))
			else
				if base.dailyAcYouhuaSwitch==1 then
					backSprie=GetButtonItem("acItemBg1.png","acItemBg2.png","acItemBg2.png",cellClick,idx,nil,nil,nil,CCRect(50,50,1,1),CCSizeMake(G_VisibleSizeWidth - 40,bgH+4))
					local bgMenu=CCMenu:createWithItem(backSprie)
					bgMenu:setTouchPriority(-(self.layerNum-1)*20-2)
					cell:addChild(bgMenu,1)
					backSpriteCenterY=backSprie:getContentSize().height/2
					bgMenu:setPosition(ccp(backSprie:getContentSize().width/2-5,backSpriteCenterY))
					menuDesc:setPosition(ccp(backSprie:getContentSize().width - 30, backSpriteCenterY))
				else
					backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),cellClick)
					backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth - 60, bgH))
					backSprie:setAnchorPoint(ccp(0,0))
					backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
					cell:addChild(backSprie,1)
					backSpriteCenterY = backSprie:getContentSize().height/2
					menuDesc:setPosition(ccp(backSprie:getContentSize().width - 30, backSpriteCenterY))
					backSprie:setPosition(ccp(5,0))
				end
			end
		
			local acName
			if acVo.type == "firstRecharge" then
				acName = getlocal("firstRechargeReward")
			elseif acVo.type == "crystalHarvest" then
				acName = getlocal("crystalYield")
			elseif acVo.type == "leveling2" then
				acName = getlocal("activity_leveling_title")
			elseif acVo.type == "autumnCarnival" then
				if acAutumnCarnivalVoApi:isAutumn()==true then
					acName = getlocal("activity_autumnCarnival_title")
				else
					acName = getlocal("activity_supplyIntercept_title")
				end
			elseif acVo.type == "slotMachine2" then
				acName = getlocal("activity_slotMachine_title")
			elseif acVo.type == "slotMachineCommon" then
				acName = getlocal("activity_slotMachine_title")
			elseif acVo.type == "grabRed" then
				if acVo.version ==1 or acVo.version ==nil then
					acName=getlocal("activity_grabRed_title")
				elseif acVo.version ==2 then
					acName=getlocal("activity_grabRed_titleB")
				elseif acVo.version ==3 then
					acName=getlocal("activity_grabRed_titleC")
				end
			elseif acVo.type == "equipSearchII" then
				if acVo.version and (acVo.version==2 or acVo.version==4 or acVo.version==5) then
					acName = getlocal("activity_equipSearchIII_title")
				elseif acVo.version ==3 or acVo.version == 1 or acVo.version >= 6 then
					acName = getlocal("activity_"..acVo.type.."_title")
				end
			elseif acVo.type == "discount" then
				if acVo.version ~=nil and (acVo.version==2 or acVo.version==3) then
					acName = getlocal("activity_BlackFriday_title")
				elseif acVo.version ~=nil and acVo.version==4  then
					acName = getlocal("activity_discount_title3")
				elseif acVo.version ~=nil and (acVo.version==5 or acVo.version==6) then
					acName = getlocal("activity_discount_newYearTitle")
				elseif acVo.version ~=nil and acVo.version == 10 then
					acName =getlocal("activity_discount_title10")
				else
					acName = getlocal("activity_discount_title")
				end            
			elseif acVo.type == "holdGround" then
				if acVo.version ==nil  or acVo.version==1 then
					acName = getlocal("activity_holdGround_title")
				elseif acVo.version ==2 then
					acName = getlocal("activity_holdGround_title_2")
				elseif acVo.version ==3 then
					acName = getlocal("activity_holdGround_title_3")
				elseif acVo.version ==4 then
					acName = getlocal("activity_holdGround_title_4")
				end
			elseif acVo.type =="dayRecharge" then
				if acVo.version ==3 then
					acName =getlocal("activity_dayRecharge_title_3")
				else
					acName =getlocal("activity_dayRecharge_title")
				end
			elseif acVo.type == "feixutansuo" then
				if acVo.version >9 then
					if 	acVo.version<14 then
						if acVo.version  ==10 then
							acVo.version = 1
						elseif acVo.version ==11 then
							acVo.version = 2
						elseif acVo.version ==12 then
							acVo.version = 3
						elseif acVo.version ==13 then
							acVo.version = 4
						end
					elseif acVo.version >= 14 then
						if acVo.version ==14 then
							acVo.version = 5
						elseif acVo.version ==15 then
							acVo.version = 6
						elseif acVo.version ==16 then
							acVo.version = 7
						elseif acVo.version ==17 then
							acVo.version = 8
						elseif acVo.version >=18 then
							acVo.version = 9				
						end
					end
				end
				if acVo.version==nil or acVo.version<5 then
					if acVo.version ==nil or acVo.version ==1 then
						acName = getlocal("activity_feixutansuo_title1")
					elseif acVo.version ==2 then
						acName = getlocal("activity_feixutansuo_title2")
					elseif acVo.version ==3 then
						acName = getlocal("activity_feixutansuo_title3")
					elseif acVo.version ==4 then
						acName = getlocal("activity_feixutansuo_title4")
					end
				elseif acVo.version >= 5 then
					if acVo.version ==5 then
						acName = getlocal("activity_feixutansuo_title5")
					elseif acVo.version ==6 then
						acName = getlocal("activity_feixutansuo_title6")
					elseif acVo.version ==7 then
						acName = getlocal("activity_feixutansuo_title7")
					elseif acVo.version ==8 then
						acName = getlocal("activity_feixutansuo_title8")
					elseif acVo.version ==9 then
						acName = getlocal("activity_feixutansuo_title9")					
					end
				end
				if base.mustmodel==1 and acFeixutansuoVoApi:getMustMode() then
					acName=getlocal("acFeixutansuoNew_title")
				end
			elseif acVo.type == "huoxianmingjiang" then 
				acName = getlocal("activity_huoxianmingjiang_title1")
			elseif acVo.type == "diancitanke" then 
				acName = getlocal("activity_diancitanke_title1")
			elseif acVo.type == "sendaccessory" then 
				acName = getlocal("activity_peijianhuzeng_title")
			elseif acVo.type == "junshijiangtan" then 
				if acVo.version ==1 or acVo.version ==nil then
					acName = getlocal("activity_junshijiangtan_title")
				else
					acName = getlocal("activity_junshijiangtan_titleB")
				end
			elseif acVo.type == "huoxianmingjianggai" then 
				acName = getlocal("activity_huoxianmingjiang_title1")
			elseif acVo.type == "taibumperweek" then 
				acName = acTitaniumOfharvestVoApi:getTitleName()
			elseif acVo.type =="zhenqinghuikui" then
				if acVo.version ==3 then
					acName = getlocal("activity_zhenqinghuikui_title3")
				elseif acVo.version ==4 or acVo.version==5 or acVo.version==6 or acVo.version==7 then
					acName = acRoulette5VoApi:getAcName()
				else
					acName = getlocal("activity_zhenqinghuikui_title")
				end
			elseif acVo.type =="moscowGamblingGai" then
				if acVo.version ==nil or acVo.version ==1 then
					acName =getlocal("activity_moscowGambling_title")
				elseif acVo.version ==2 then
					acName = getlocal("activity_monsterComeback_title")
				elseif acVo.version ==3 then
					acName = getlocal("activity_kuangnuzhishi_title")
				end
			elseif acVo.type =="chongzhiyouli" then
				acName = acChongZhiYouLiVoApi:getAcName()
			elseif acVo.type =="songjiangling" then
				acName = getlocal("activity_SendGeneral_title")
			elseif acVo.type =="baifudali" then
				if acVo.version == 3 then
					acName = getlocal("activity_baifudali_titleTW")
				else
					acName = getlocal("activity_baifudali_title")
				end
			elseif acVo.type =="shengdanbaozang" then
				if acVo.version ==1 or acVo.version ==2 or acVo.version ==nil then
					acName = getlocal("activity_shengdanbaozang_title")
				elseif acVo.version ==3 or acVo.version == 4 then
					acName = getlocal("activity_mysteriousArms_title")
				end
			elseif acVo.type =="xingyunzhuanpan" then
				 acName =getlocal("activity_mayDay_title")
			elseif acVo.type =="shengdankuanghuan" then
				 if acVo.version ~=3 then
				 	acName =getlocal("activity_shengdankuanghuan_title")
				 elseif acVo.version ==3 then
				 	acName =getlocal("activity_shengdankuanghuan_titleB")
				 end
			elseif acVo.type =="yunxingjianglin" then
				acName =getlocal("activity_meteoriteLanding_title")
		    elseif acVo.type =="hongchangyuebing" then
		    	acName =getlocal("activity_hongchangyuebing_title")

			elseif acVo.type =="huiluzaizao" then
				acName =getlocal("activity_recycling_title")
			elseif acVo.type =="kafkagift" then
				local version =  acKafkaGiftVoApi:getVersion()
				if version==nil or version==1 or version==2 then
					acName =getlocal("activity_kafkagift_title")
				else
					acName =getlocal("activity_kafkagift_title" .. version)
				end
			elseif acVo.type =="twohero" then  --将领礼包
				acName =getlocal("activity_heroGift_title")
			elseif acVo.type =="ydjl2" then
				acName =getlocal("activity_acYueduTwoHero_title")
			elseif acVo.type =="yuedujiangling" then
				acName =getlocal("activity_acYueduHero_title")
			elseif acVo.type =="haoshichengshuang" then
				acName =getlocal("activity_haoshichengshuang_title")
			elseif acVo.type =="gangtieronglu" then
				acName =getlocal("activity_gangtieronglu_title")
			elseif acVo.type =="xingyunpindian" then
				acName =getlocal("activity_xingyunpindian_title")
			elseif acVo.type =="chongzhisongli" then -- 累计充值送好礼
		        acName =getlocal("activity_chongzhisongli_title_1")
		    elseif acVo.type =="danrichongzhi" then -- 单日充值
		        acName =getlocal("activity_danrichongzhi_title_1")
		    elseif acVo.type =="mrcz" then --每日充值送好礼（新手绑定）
		    	acName =getlocal("activity_dailyRechargeByNewGuider_title")
		    elseif acVo.type =="danrixiaofei" then -- 单日消费
		        acName =getlocal("activity_danrixiaofei_title_1")
			elseif acVo.type =="xiaofeisongli" then
				acName =getlocal("activity_xiaofeisongli_title_1")
			elseif acVo.type =="ybsc" then
				acName =getlocal("activity_yuebingshencha_title")
				if acYuebingshenchaVoApi:getVersion()==2 then
					acName =getlocal("activity_yuebingshencha_title_2")
				end
			elseif acVo.type =="jffp" then
				acName =getlocal("activity_jffp_title")	
			elseif acVo.type =="jiejingkaicai" then
				acName =getlocal("activity_jiejingkaicai_title")
			elseif acVo.type =="mingjiangzailin" then
				acName =getlocal("activity_mingjiangzailin_title")
			elseif acVo.type =="yijizaitan" then
				acName =getlocal("activity_yijizaitan_title")
			elseif acVo.type =="tankbattle" then
				acName =getlocal("activity_tankbattle_title")
			elseif acVo.type =="shengdanqianxi" then
				if(acChrisEveVoApi and (acChrisEveVoApi:isNormalVersion() or acChrisEveVoApi:getVersion() == 5))then
					acName =getlocal("activity_chrisEve_title_1")
				else
					acName =getlocal("activity_chrisEve_title")
				end
			elseif acVo.type =="newyeargift" then
				acName =getlocal("activity_newyeargift_title")
			elseif acVo.type =="newyeareva" then
				if acNewYearsEveVoApi:getAcShowType()==acNewYearsEveVoApi.acShowType.TYPE_2 then
					acName =getlocal("activity_newyearseve_title_1")
				else
				acName =getlocal("activity_newyearseve_title")
				end
			elseif acVo.type =="wanshengjiedazuozhan" then
				local version=acWanshengjiedazuozhanVoApi:getVersion()
				if version and version>1 then
					acName =getlocal("activity_wanshengjiedazuozhan_title_"..version)
				else
					acName =getlocal("activity_wanshengjiedazuozhan_title")
				end
			elseif acVo.type =="chunjiepansheng" then
				local version=acChunjiepanshengVoApi:getVersion()
				acName =getlocal("activity_chunjiepansheng_title" .. "_ver" .. version)
			elseif acVo.type =="smcj" then
				acName =getlocal("activity_smcj_title")
			elseif acVo.type =="hljb" then
				acName =getlocal("activity_hljb_title")
			elseif acVo.type =="double11new" then
				acName = getlocal("activity_double11New_title")
			elseif acVo.type =="double11" then
				if acVo.version ==nil or acVo.version ==1 then
					acName =getlocal("activity_double11_title")
				elseif acVo.version ==2 then
					acName =getlocal("activity_cnNewYear_title")
				elseif acVo.version >2 then
					acName = getlocal("activity_double11_title_ver_"..acVo.version)
				end
			elseif acVo.type =="new112018" then
				if acVo.version == nil or acVo.version == 1 then
					acName = getlocal("activity_new112018_title")
				end
				if acName==nil or acName=="" then
					acName = getlocal("activity_new112018_title")
				end
			elseif acVo.type =="rechargeCompetition" then
				acName =getlocal("activity_rechargeCompetition_title")
			elseif acVo.type=="dailyEquipPlan" then
				acName =getlocal("activity_dailyequip_title")
			elseif acVo.type=="seikoStoneShop" then
				acName =getlocal("activity_seikostone_shop_title")
			elseif acVo.type=="anniversaryBless" then
				acName =getlocal("activity_anniversaryBless_title")
			elseif acVo.type=="blessingWheel" then
				acName =getlocal("activity_blessingwheel_title")
			elseif acVo.type=="rechargebag" then
				acName =getlocal("activity_rechargebag_title")
			elseif acVo.type=="aoyunjizhang" then
				acName=getlocal("activity_aoyunjizhang_title")
			elseif acVo.type=="midautumn" then
				acName=acMidAutumnVoApi:getVersion() == 3 and getlocal("activity_midautumn_v2_title") or getlocal("activity_midautumn_title")
			elseif acVo.type=="threeyear" then
				acName=getlocal("activity_threeyear_title")
			elseif acVo.type=="djrecall" then
				acName=getlocal("activity_generalRecall_title")
			elseif acVo.type=="wdyo" then
				acName=getlocal("activity_loversDay_title")
			elseif acVo.type=="zjfb" then
				acName =getlocal("activity_zjfb_title")
			elseif acVo.type=="ramadan" then
				acName=getlocal("activity_ramadan_title")
			elseif acVo.type=="phlt" then
				acName=getlocal("activity_phlt_title")
			elseif acVo.type=="hxgh" then
				acName=getlocal("activity_hxgh_title")
			elseif acVo.type=="zzrs" then
				acName=getlocal("activity_zzrs_title")
			elseif acVo.type=="fuyunshuangshou" then
				acName=getlocal("activity_fyss_title")
			elseif acVo.type=="znkh" then
				if acVo.version==3 then
					acName=getlocal("activity_znkh_title_3")
				else
					acName=getlocal("activity_znkh2017_title")
				end
			elseif acVo.type=="lmqrj" then
				if acLmqrjVoApi and acLmqrjVoApi:getVersion()==2 then
					acName=getlocal("activity_lmqrj_title_v2")
				else
					acName=getlocal("activity_lmqrj_title")
				end
			elseif acVo.type=="ydcz" then
				acName=getlocal("activity_ydcz_title")
			elseif acVo.type=="tqbj" then
				if acTqbjVoApi:getVersion()==7 then
					acName=getlocal("activity_tqbj_ver2_title")
				else
					acName=getlocal("activity_tqbj_title")
				end
			elseif acVo.type=="xstq" then
				acName=getlocal("activity_xstq_title")
			elseif acVo.type=="smbd" then
				acName=getlocal("activity_smbd_title")
			elseif acVo.type=="thfb" then
				if acVo.version==1 then
					acName=getlocal("activity_thfb_title")
				else
					acName=getlocal("activity_thfb_v"..acVo.version.."_title")
				end
			elseif acVo.type == "xcjh" then
				if acXcjhVoApi:getVersion() == 1 then
					acName = getlocal("activity_xcjh_title")
				else
					acName = getlocal("activity_xcjh_title_v2")
				end
			elseif acVo.type=="mjzy" then
				acName=getlocal("activity_mjzy_title")
			elseif acVo.type=="xlys" then
				acName=getlocal("activity_xlys_title")
			elseif acVo.type == "znkh2018" then
				acName = getlocal("activity_znkh2018_title")
			elseif acVo.type == "kfcz" then
				acName = getlocal("activity_kfcz_title")
			elseif acVo.type == "zntp" then
				acName = getlocal("activity_zntp_title")
			elseif acVo.type == "znjl" and acVo.version == 2 then
				acName = getlocal("active_znsd_title")
			elseif acVo.type == "hjld" then
				acName = getlocal("acMemoryServer_title")
			elseif acVo.type == "xjlb" then
				acName = acCashGiftBagVoApi:getActiveTitle()
			else
				local arr=Split(acVo.type,"_")
				if arr[1]=="buyreward" then
					acName = getlocal("activity_buyreward_title" .. acBuyrewardVoApi:getNameType(acVo.type))
				elseif arr[1]=="pjjnh" then
					acName = getlocal("activity_pjjnh_title")
				elseif arr[1]=="olympic" then
					acName =getlocal("activity_olympic_title")
				elseif arr[1]=="luckcard" then
					acName =getlocal("activity_luckyPoker_title")
				elseif arr[1]=="customLottery" then
					acName =getlocal("activity_"..arr[1].."_title")
				elseif arr[1] =="wsjdzz" then
					if(acWsjdzzVoApi and acWsjdzzVoApi:isNormalVersion(acVo.type))then
						acName =getlocal("activity_wanshengjiedazuozhan_title_n")
					else
						acName =getlocal("activity_wanshengjiedazuozhan_title")
					end
				elseif arr[1] =="wsjdzz2017" then
					acWsjdzzIIVoApi:setActiveName(acVo.type)
					if acWsjdzzIIVoApi:getVersion() == 2 or acWsjdzzIIVoApi:getVersion() == 4 then
						acName =getlocal("activity_wanshengjiedazuozhan_title_n")
					elseif acWsjdzzIIVoApi:getVersion() == 1 then
						acName =getlocal("activity_wsjdzz2017_title")
					elseif acWsjdzzIIVoApi:getVersion() == 3 then
						acName = getlocal("activity_wanshengjiedazuozhan_title_p")
					end
				elseif arr[1] =="openyear" then
					if acOpenyearVoApi:getAcShowType(acVo.type)==acOpenyearVoApi.acShowType.TYPE_2 then
						acName =getlocal("activity_openyear_title_1")
					elseif  acOpenyearVoApi:getAcShowType(acVo.type)==acOpenyearVoApi.acShowType.TYPE_3 then
						acName =getlocal("activity_openyear_title_3")
					else
						acName =getlocal("activity_openyear_title")
					end
				elseif arr[1] =="gej2016" then
					acName =getlocal("activity_gej2016_title")
				elseif arr[1] =="nljj" then
					acName =getlocal("activity_nljj_title")
				elseif arr[1] =="qxtw" then
					acName =getlocal("activity_qxtw_title")
				elseif arr[1]=="gzhx" then
					acName = getlocal("activity_gzhx_title")
				elseif arr[1]=="gqkh" then
					if acGqkhVoApi:getAcShowType(acVo.type)==acGqkhVoApi.acShowType.TYPE_2 then
						acName = getlocal("activity_gqkh_title_1")
					else
						acName = getlocal("activity_gqkh_title")
					end
				elseif arr[1]=="qmsd" then
					acName = getlocal("activity_qmsd_title")
				elseif arr[1]=="khzr" then
					acName = acKhzrVoApi:getVersion() == 1 and getlocal("activity_khzr_title") or getlocal("activity_khzr_title_v2")
				elseif arr[1]=="mjzx" then
					acName = getlocal("activity_mjzx_title")
				elseif arr[1]=="yrj" then
					if acYrjVoApi:getVersion() == 1 then
						acName = getlocal("activity_yrj_title")
					elseif acYrjVoApi:getVersion() == 2 then
						acName = getlocal("activity_yrjV2_title")
					end
				elseif arr[1]=="christmasfight" then
					if acChristmasFightVoApi:getAcShowType()==acChristmasFightVoApi.acShowType.TYPE_2 then
						acName = getlocal("activity_christmasfight_title_1")
					else
						acName = getlocal("activity_christmasfight_title")
					end
				elseif arr[1]=="duanwu" then
					if acDuanWuVoApi:getVersion() == 1 then
						acName = getlocal("activity_duanwu_title")
					else
						acName = getlocal("activity_duanwu2_title")
					end
				elseif arr[1]=="wpbd" then
					acName = getlocal("activity_wpbd_title")
				elseif arr[1]=="dlbz" then
					acName = getlocal("activity_dlbz_title")
				elseif arr[1]=="czhk" then
					acName = getlocal("activity_czhk_title")
				elseif arr[1]=="wsj2018" then
					local version = acHalloween2018VoApi:getVersion()
					if version==1 then
						acName=getlocal("activity_wsj2018_title")
					else
						acName=getlocal("activity_wsj2018_ver"..version.."_title")
					end
				elseif arr[1] == "mjcs" then
					if acMjcsVoApi:getVersion() == 1 then
						acName = getlocal("activity_mjcs_title")
					else
						acName = getlocal("activity_mjcs_title_v2")
					end
				
				elseif arr[1] == "jblb" then
					acName = acCustomVoApi:getActiveTitle(arr[2])
				else
					acName = getlocal("activity_"..acVo.type.."_title")
				end
				
			end
			if acVo.type == "firstRecharge" then
				acIconUrl = "firstRechargeIcon.png"
			elseif acVo.type =="xingyunzhuanpan" then
				 acIconUrl = "Icon_BG.png"
				 addIcon = CCSprite:createWithSpriteFrameName("acMayDayBgGold.png")
				 addIcon:setScale(0.8)				 
			elseif acVo.type == "newyeargift" then
				acIconUrl = "Icon_BG.png"
				addIcon = CCSprite:createWithSpriteFrameName("friendBtn.png")
				addIcon:setScale(0.8)
			elseif acVo.type == "discount" then
				acIconUrl = "Icon_BG.png"
				local function timeIconClick( ... )
				end
				addIcon = LuaCCSprite:createWithSpriteFrameName("IconTime.png",timeIconClick)
				addIcon:setScale(1.5)        
			elseif acVo.type == "moscowGambling" then
				acIconUrl = "wukelanLv3.png"
			elseif acVo.type == "moscowGamblingGai" then
				acIconUrl = "Icon_BG.png"
				if acVo.version ==1 or acVo.version ==nil then
					addIconStr = "wukelanLv3.png"
				elseif acVo.version ==2 then
					addIconStr = "SturmtigerLv3.png"
				elseif acVo.version ==3 then
					addIconStr = "IconTank_10113.png"
				end
				local function timeIconClick( ... )
				end
				addIcon = LuaCCSprite:createWithSpriteFrameName(addIconStr,timeIconClick)
				addIcon:setScale(0.5)    
			elseif acVo.type == "fbReward" then
				acIconUrl = "TankLv5.png"
			elseif acVo.type == "baseLeveling" or acVo.type == "leveling" or acVo.type == "leveling2" then
				acIconUrl = "Icon_zhu_ji_di.png"
			elseif acVo.type =="mrcz" then--每日充值送好礼（新人绑定）
		    	acIconUrl = "Icon_BG.png"
		    	local function goldIconClick( ... )
				end
		    	addIcon = LuaCCSprite:createWithSpriteFrameName("iconGoldNew3.png",goldIconClick)
		    	addIcon:setScale(0.8)

			elseif acVo.type == "dayRecharge" then
				acIconUrl = "Icon_BG.png"
				local function goldIconClick( ... )
				end
				if acVo.version ==3 then
					addIconStr="360LOGO.png"
				else
					addIconStr="GoldImage.png"
				end
				addIcon = LuaCCSprite:createWithSpriteFrameName(addIconStr,goldIconClick)
				if acVo.version ==3 then 
					addIcon:setScale(0.4)
				end
				-- addIcon:setScale(1.5) 
			elseif acVo.type == "dayRechargeForEquip" then
				acIconUrl = "Icon_BG.png"
				local function touch( ... )
				end
				addIcon = accessoryVoApi:getAccessoryIcon("a16",80,80,touch)
			elseif acVo.type == "fightRank" then
				acIconUrl = "Icon_BG.png"
				local function firstIconClick( ... )
				end
				addIcon = LuaCCSprite:createWithSpriteFrameName("top1.png",firstIconClick)
			elseif acVo.type == "wheelFortune" then
				acIconUrl = "Icon_Turntable.png"
			elseif acVo.type == "allianceLevel" then
				acIconUrl = "alliance_icon.png"
			elseif acVo.type == "allianceFight" then
				acIconUrl = "tech_fight_exp_up.png"
			elseif acVo.type == "personalHonor" then
				acIconUrl = "item_xunzhang_02.png"
			elseif acVo.type == "personalCheckPoint" then
				acIconUrl = "Icon_BG.png"
				local function goldIconClick( ... )
				end
				addIcon = LuaCCSprite:createWithSpriteFrameName("mainBtnCheckpoint.png",goldIconClick)
			elseif acVo.type == "totalRecharge" or acVo.type == "totalRecharge2" then
				acIconUrl = "Icon_BG.png"
				local function goldIconClick( ... )
				end
				addIcon = LuaCCSprite:createWithSpriteFrameName("GoldImage.png",goldIconClick)
			elseif acVo.type == "crystalHarvest" then
				acIconUrl = "resourse_normal_gold.png"
			elseif acVo.type == "equipSearch" then
				acIconUrl = "item_developmentBox.png"
			elseif acVo.type == "rechargeRebate" then
				acIconUrl = "Icon_BG.png"
				local function goldIconClick( ... )
				end
				addIcon = LuaCCSprite:createWithSpriteFrameName("GoldImage.png",goldIconClick)
			elseif acVo.type == "customRechargeRebate" then
				acIconUrl = "Icon_BG.png"
				local function goldIconClick( ... )
				end
				addIcon = LuaCCSprite:createWithSpriteFrameName("GoldImage.png",goldIconClick)
			elseif acVo.type == "monsterComeback" then
				acIconUrl = "SturmtigerLv3.png"
			elseif acVo.type=="growingPlan" then
				acIconUrl = "Icon_grown.png"
			elseif acVo.type=="harvestDay" then
				acIconUrl = "Icon_novicePacks.png"
			elseif acVo.type=="accessoryEvolution" then
				acIconUrl = "accessoryP6.png"
			elseif acVo.type=="accessoryFight" then
				acIconUrl = "Icon_BG.png"
				local function goldIconClick( ... )
				end
				addIcon = LuaCCSprite:createWithSpriteFrameName("mainBtnAccessory.png",goldIconClick)
			elseif acVo.type=="jsss" then
				acIconUrl = "acJsys_icon.png"
			elseif acVo.type=="allianceDonate" then
				acIconUrl = "tech_fight_exp_up.png"
			elseif acVo.type == "equipSearchII" then
				if acVo.version and (acVo.version==4 or acVo.version==5) then
					acIconUrl = "Icon_BG.png"
					local function IconClick( ... )
					end
					addIcon = LuaCCSprite:createWithSpriteFrameName("acbaozangIcon.png",IconClick)
				else
					acIconUrl = "item_developmentBox.png"
				end
			elseif acVo.type=="vipRight" then
				acIconUrl = "Icon_novicePacks.png"
			elseif acVo.type=="heartOfIron" then
				acIconUrl = "item_buff_peace2.png"
			elseif acVo.type=="userFund" then
				acIconUrl = "Icon_grown.png"
			elseif acVo.type=="vipAction" then
				acIconUrl = "Icon_prompt_3.png"
			elseif acVo.type=="investPlan" then
				acIconUrl = "Icon_grown.png"
			elseif acVo.type == "hardGetRich" then
				acIconUrl = "item_buff_uranium_up2.png"
			elseif acVo.type == "wheelFortune4" then
				acIconUrl = "Icon_Turntable.png"
			elseif acVo.type == "openGift" then
				acIconUrl = "item_warBox.png"
			elseif acVo.type == "wheelFortune2" then
				acIconUrl = "Icon_Turntable.png"
			elseif acVo.type == "wheelFortune3" then
				acIconUrl = "Icon_Turntable.png"
			elseif acVo.type == "stormrocket" then
				acIconUrl = "StormRocket.png"
			elseif acVo.type == "grabRed" then
				acIconUrl = "item_baoxiang_09.png"
			elseif acVo.type == "armsRace" then
				acIconUrl = "Icon_tan_ke_gong_chang.png"
			elseif acVo.type == "slotMachine" or acVo.type == "slotMachine2" or acVo.type == "slotMachineCommon" then
				acIconUrl = "ShadowTank.png"
			elseif acVo.type == "customLottery1" then
				acIconUrl = "ShadowTank.png"
			elseif acVo.type == "shareHappiness" then
				acIconUrl = "item_luckyCoinsBig.png"
			elseif acVo.type =="kafkagift" then
				acIconUrl ="Icon_BG.png"
				local function timeIconClick( ... )
				end
				local addIconStr="unKnowIcon.png"
				addIcon = LuaCCSprite:createWithSpriteFrameName(addIconStr,timeIconClick)
				addIcon:setScale(0.8)
			elseif acVo.type == "holdGround" then
				acIconUrl = "Icon_BG.png"
				local function timeIconClick( ... )
				end
				local addIconStr=""
				if acVo.version == 1 or acVo.version ==nil or acVo.version ==2 then
					addIconStr="7days.png"
				elseif acVo.version == 3 then
					addIconStr="360LOGO.png"
				elseif acVo.version ==4 then
					addIconStr="yuandanIcon.png"
				end
				addIcon = LuaCCSprite:createWithSpriteFrameName(addIconStr,timeIconClick)
				if acVo.version ==3 then
					addIcon:setScale(0.4)
				else
					addIcon:setScale(0.8)
				end
			elseif acVo.type == "holdGround1" then
				acIconUrl = "7days.png"
			elseif acVo.type == "fundsRecruit" then
				acIconUrl = "Icon_gong_hui.png"
			elseif acVo.type == "continueRecharge" then
				acIconUrl = "item_productionBox.png"
			elseif acVo.type == "lxcz" then
				acIconUrl = "item_productionBox.png"
			elseif acVo.type == "rewardingBack" then
				acIconUrl = "Icon_BG.png"
				local function goldIconClick( ... )
				end
				addIcon = LuaCCSprite:createWithSpriteFrameName("iconGold3.png",goldIconClick)
				addIcon:setScale(0.8)
			elseif acVo.type =="armamentsUpdate1" then
				acIconUrl ="TankLv6.png"
			elseif acVo.type =="armamentsUpdate2" then
				acIconUrl ="ArtilleryLv6.png"
			elseif acVo.type == "miBao" then
				acIconUrl = "item_luckyCoinsBig.png"
			elseif acVo.type == "autumnCarnival" then
				acIconUrl = "Icon_novicePacks.png"
			elseif acVo.type == "refitPlanT99" then
				acIconUrl = "IconT99.png"
			elseif acVo.type == "calls" then
				acIconUrl = "k100.png"
			elseif acVo.type == "newTech" then
				acIconUrl = "Icon_rapidProduction.png"
			elseif acVo.type == "luckUp" then
				acIconUrl = "item_buff_all_up.png"
			elseif acVo.type == "republicHui" then
				acIconUrl = "IconTank59.png"
			elseif acVo.type == "nationalCampaign" then
				acIconUrl = "item_buff_damage_plus.png"
			elseif acVo.type == "ghostWars" then
                 if G_curPlatName()=="13" or G_curPlatName()=="androidzhongshouyouko" or G_curPlatName()=="androidzsykonaver" or G_curPlatName()=="androidzsykoolleh" or G_curPlatName()=="androidzsykotstore" then
                    acIconUrl = "item_buff_speed_up.png"
                else
                    acIconUrl = "Icon_BG.png"
                    local function timeIconClick( ... )
                    end
                    addIcon = LuaCCSprite:createWithSpriteFrameName("ghost.png",timeIconClick)
                    addIcon:setScale(0.5)
                end
			elseif acVo.type == "doorGhost" then
				acIconUrl = "Icon_BG.png"
				local function timeIconClick( ... )
				end
				addIcon = LuaCCSprite:createWithSpriteFrameName("door.png",timeIconClick)
				addIcon:setScale(0.25)
			elseif acVo.type == "preparingPeak" then
				acIconUrl = "Icon_BG.png"
				local function timeIconClick( ... )
				end
				addIcon = LuaCCSprite:createWithSpriteFrameName("IconTime.png",timeIconClick)
				addIcon:setScale(1.5)
			elseif acVo.type == "singles" then
				acIconUrl = "guanggun.png"
			elseif acVo.type == "cuikulaxiu" then
				acIconUrl = "Icon_BG.png"
				local function timeIconClick( ... )
				end
				addIcon = LuaCCSprite:createWithSpriteFrameName("military_rank_20.png",timeIconClick)
			elseif acVo.type == "jidongbudui" then
				acIconUrl = "Icon_BG.png"
				local function timeIconClick( ... )
				end
				addIcon = LuaCCSprite:createWithSpriteFrameName("Turkey.png",timeIconClick)
			elseif acVo.type == "baifudali" then
				acIconUrl = "Icon_BG.png"
				local function timeIconClick( ... )
				end
				local addIconStr=""
				if acVo.version == 1 then
					addIconStr="360LOGO.png"
				elseif acVo.version == 2 then
					addIconStr="3KLOGO.png"
				elseif acVo.version == 3 then
					addIcon =LuaCCSprite:createWithFileName("public/caidan.png",timeIconClick)
					addIcon:setScale(0.8)
				end
				if G_curPlatName() =="11" or G_curPlatName() =="androidsevenga" then
					addIconStr = "sevenga.png"
				end
				if acVo.version ~=3 then
					addIcon = LuaCCSprite:createWithSpriteFrameName(addIconStr,timeIconClick)
					addIcon:setScale(0.4)
					if G_curPlatName() =="11" or G_curPlatName() =="androidsevenga" then
						addIcon:setScale(0.7)
					end
				end
			elseif acVo.type == "feixutansuo" then
				acIconUrl = "Icon_BG.png"
				local function timeIconClick( ... )
				end
				local addIconStr = ""
				if acVo.version >9 then
					if 	acVo.version<14 then
						if acVo.version  ==10 then
							acVo.version = 1
						elseif acVo.version ==11 then
							acVo.version = 2
						elseif acVo.version ==12 then
							acVo.version = 3
						elseif acVo.version ==13 then
							acVo.version = 4
						end
					elseif acVo.version >= 14 then
						if acVo.version ==14 then
							acVo.version = 5
						elseif acVo.version ==15 then
							acVo.version = 6
						elseif acVo.version ==16 then
							acVo.version = 7
						elseif acVo.version ==17 then
							acVo.version = 8
						elseif acVo.version >=18 then
							acVo.version = 9				
						end
					end
				end
				if acVo.version ==nil or acVo.version <5 then
					if acVo.version ==1 or acVo.version ==nil then
						addIconStr="IconTujiu.png"
					elseif acVo.version ==2 then
						addIconStr="IconT99.png"
					elseif acVo.version == 3 then
						addIconStr="fightingElephantTank.png"
					elseif acVo.version ==4 then
						addIconStr="largeMouseTank.png"
					end
				elseif acVo.version >= 5 then
					if acVo.version ==5 then
						addIconStr="SandstormIcon.png"
					elseif acVo.version ==6 then
						addIconStr="IconTank_10094.png"
					elseif acVo.version ==7 then
						addIconStr="IconTank_10114.png"
					elseif acVo.version ==8 then
						addIconStr="IconTank_10124.png"
					elseif acVo.version ==9 then
						addIconStr="IconTank_10134.png"
					end
				end
				addIcon = LuaCCSprite:createWithSpriteFrameName(addIconStr,timeIconClick)
				addIcon:setScale(0.5) -- 适图而定
			elseif acVo.type == "kuangnuzhishi" then
				acIconUrl = "Icon_BG.png"
				local function timeIconClick( ... )
				end
				addIcon = LuaCCSprite:createWithSpriteFrameName("kuangnuTikect.png",timeIconClick)
				addIcon:setScale(0.7)
			elseif acVo.type == "zhenqinghuikui" then
				acIconUrl = "Icon_BG.png"
				local function timeIconClick( ... )
				end
				local addIconStr=""
				if acVo.version == 1 then
					addIconStr="huikui_reward1.png"
				elseif acVo.version == 2 then
					addIconStr="kuangnuTikect.png"
				elseif acVo.version ==3 then
					addIconStr ="yuandanIcon.png"
				elseif acVo.version ==4 then 
					addIconStr ="jingDongCard.png"
				elseif acVo.version ==5 then
					addIconStr ="kuangnuTikect.png"
				elseif acVo.version ==6 then
					addIconStr ="jingDongCard.png"
				elseif acVo.version ==7 then
					addIconStr ="kuangnuTikect.png"
				end
				addIcon = LuaCCSprite:createWithSpriteFrameName(addIconStr,timeIconClick)
				addIcon:setScale(0.8)
			elseif acVo.type == "shengdanbaozang" then
				acIconUrl = "Icon_BG.png"
				local function timeIconClick( ... )
				end
				local changeIcon = "CandyBar.png"
				if acVo.version ==3 or acVo.version ==4 then
					changeIcon ="mysteriousArmsIcon.png"
				end
				addIcon = LuaCCSprite:createWithSpriteFrameName(changeIcon,timeIconClick)
				addIcon:setScale(0.4)
				if acVo.version ==3 or acVo.version ==4 then
					addIcon:setScale(0.8)
				end
			elseif acVo.type == "shengdankuanghuan" then
				if acVo.version ~=3 then
					acIconUrl = "ChristmasTreeIcon.png"
				elseif acVo.version ==3 then
					acIconUrl = "arsenalIcon.png"
				end
			elseif acVo.type == "yuandanxianli" then
				if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" then
					acIconUrl = "yuandanIcon.png"
				else
					acIconUrl = "Icon_BG.png"
					local function timeIconClick( ... )
					end
					addIcon = LuaCCSprite:createWithSpriteFrameName("mainBtnGift.png",timeIconClick)
				end
			elseif acVo.type == "onlineReward" then
				acIconUrl = "Icon_novicePacks.png"
			elseif acVo.type == "ywzq" then
				acIconUrl = "acYwzq2018Icon.png"
			elseif acVo.type == "online2018" then
				acIconUrl = "Icon_BG.png"
				addIcon = CCSprite:createWithSpriteFrameName("propBox5.png")
				addIcon:setScale(0.7)
			elseif acVo.type == "tankjianianhua" then
				acIconUrl = "Icon_novicePacks.png"
			elseif acVo.type == "xuyuanlu" then
				if acVo.version == nil or acVo.version == 1 then
					acIconUrl = "newYearFuzi.png"
				elseif acVo.version == 2 then
					acIconUrl = "Icon_BG.png"
					local function timeIconClick( ... )
					end
					addIcon = LuaCCSprite:createWithSpriteFrameName("WishingStove.png",timeIconClick)
					addIcon:setScale(0.15)
				end
			elseif acVo.type == "shuijinghuikui" then
				acIconUrl = "resourse_normal_gold.png"
			elseif acVo.type == "xinchunhongbao" then
				acIconUrl = "Icon_BG.png"
				local function timeIconClick( ... )
				end
                addIcon = LuaCCSprite:createWithSpriteFrameName("acBigGift.png",timeIconClick)
                if G_curPlatName()=="0" or G_curPlatName()=="21" or G_curPlatName()=="androidarab" then
                    addIcon = LuaCCSprite:createWithSpriteFrameName("acSmallGift.png",timeIconClick)
                end

				addIcon:setScale(0.5)
			elseif acVo.type == "huoxianmingjiang" then
				acIconUrl = "Icon_novicePacks.png"
				if acVo.version <6 or acVo.version ==nil then
					if acVo.version==nil or acVo.version== 1 or acVo.version== 3 then
						addIcon=heroVoApi:getHeroIcon("h26")
						addIcon:setScale(0.65)   
					elseif acVo.version == 2 or acVo.version== 4 then
						addIcon=heroVoApi:getHeroIcon("h15")
						addIcon:setScale(0.65)
					elseif acVo.version ==5 then
						addIcon=heroVoApi:getHeroIcon("h3")
						addIcon:setScale(0.65)
					end
				else
					if acVo.version ==6 then
						addIcon=heroVoApi:getHeroIcon("h24")
						addIcon:setScale(0.65)
					elseif acVo.version ==7 then
						addIcon=heroVoApi:getHeroIcon("h13")
						addIcon:setScale(0.65)
					elseif acVo.version ==8 then
						addIcon=heroVoApi:getHeroIcon("h1")
						addIcon:setScale(0.65)
					elseif acVo.version ==9 then
						addIcon=heroVoApi:getHeroIcon("h14")
						addIcon:setScale(0.65)
					elseif acVo.version ==10 then
						addIcon=heroVoApi:getHeroIcon("h2")
						addIcon:setScale(0.65)
					end
				end
			elseif acVo.type == "twohero" then
				acIconUrl = "Icon_novicePacks.png"
				addIcon=heroVoApi:getHeroIcon(tostring(acHeroGiftVoApi:getFirstIcon( )))
				addIcon:setScale(0.65) 
			elseif acVo.type == "taibumperweek" then
				acIconUrl = "resourse_normal_uranium.png"
			elseif acVo.type == "junshijiangtan" then
				acIconUrl = "serverWarPIcon.png"
			elseif acVo.type == "huoxianmingjianggai" then
				acIconUrl = "Icon_novicePacks.png"
				local award4 = acMingjiangVoApi:getAward(4)
				addIcon=heroVoApi:getHeroIcon(award4.key)
				addIcon:setScale(0.65)
			elseif acVo.type == "diancitanke" then 
				acIconUrl = "IconTank_10144.png"
			elseif acVo.type == "junzipaisong" then
				acIconUrl = "item_baoxiang_13.png"
				if acVo.version ==2 then
					acIconUrl ="item_baoxiang_27.png"
				end
			elseif acVo.type == "chongzhiyouli" then
				acIconUrl = "Icon_BG.png"
				local function timeIconClick( ... )
				end
				addIcon = LuaCCSprite:createWithSpriteFrameName("GoldImage.png",timeIconClick)
			elseif acVo.type == "songjiangling" then
				acIconUrl ="Icon_BG.png"
				local function timeIconClick( ... )
				end
				local iconStr
				if version ==1 or version==nil then
					iconStr="mainBtnGift.png"
				end
				addIcon = LuaCCSprite:createWithSpriteFrameName(iconStr,timeIconClick)	
				addIcon:setScale(0.8)	
			elseif acVo.type == "banzhangshilian" then
				acIconUrl ="WarBuffCommander.png"
			elseif acVo.type == "yunxingjianglin" then
				acIconUrl = "alien_tech_res_3.png"		
			elseif acVo.type =="huiluzaizao" then
				acIconUrl ="Icon_BG.png"
				local function timeIconClick( ... )
				end
				local iconIn ="IconTank_10114.png"
				if acVo.version ==2 then
					iconIn ="IconTujiu.png"
				end
				addIcon = LuaCCSprite:createWithSpriteFrameName(iconIn,timeIconClick)
				addIcon:setScale(0.5)
			elseif acVo.type == "hongchangyuebing" then
				acIconUrl = "IconTank_10134.png"
			elseif acVo.type == "alienbumperweek" then
				acIconUrl = "alien_tech_res_2.png"	
			elseif acVo.type == "ydjl2" then
				acIconUrl = "Icon_BG.png"
				-- local award = acYueduHeroTwoVoApi:getIconReward()
				local iconName
				if(platCfg.platCfgHeroCartoonPhoto[G_curPlatName()])then
					iconName="ship/Hero_Icon_Cartoon/hero_icon_0.png"
				else
					iconName="ship/Hero_Icon/hero_icon_0.png"
				end
				addIcon=CCSprite:create(iconName)--heroVoApi:getHeroIcon(award.key)--hero_icon_0
				addIcon2=CCSprite:createWithSpriteFrameName("questionMark.png")
				addIcon:setScale(0.45)
			elseif acVo.type == "yuedujiangling" then
				acIconUrl = "Icon_novicePacks.png"
				local award = acYueduHeroVoApi:getIconReward()
				addIcon=heroVoApi:getHeroIcon(award.key)
				addIcon:setScale(0.65)
			elseif acVo.type =="twohero" then  --将领礼包 列表icon 需要修改
				acIconUrl = "Icon_novicePacks.png"	
			elseif acVo.type == "sendaccessory" then	
				acIconUrl = "Icon_novicePacks.png"
				addIcon=GetBgIcon("item_baoxiang_101.png",nil,nil,80,100)
			elseif acVo.type == "haoshichengshuang" then	
				acIconUrl = "Icon_novicePacks.png"
				addIcon=CCSprite:createWithSpriteFrameName("acHSCSkabei.png")
			elseif acVo.type =="double11new" then
				acIconUrl ="Icon_BG.png"
				addIcon=CCSprite:createWithSpriteFrameName("friendBtn.png")
				addIcon:setScale(0.7)
			elseif acVo.type =="double11" then
				acIconUrl ="Icon_BG.png"
				if acVo.version ==nil or acVo.version ==1 or acVo.version > 2 then
					addIcon=CCSprite:createWithSpriteFrameName("friendBtn.png")
					addIcon:setScale(0.7)
				elseif acVo.version ==2 then
					local function noData( )end 
					addIcon=LuaCCSprite:createWithFileName("public/newYearIcon.png",noData)
					addIcon:setScale(0.8)
				end
			elseif acVo.type =="new112018" then
				acIconUrl ="Icon_BG.png"
				if acVo.version ==nil or acVo.version ==1 then
					addIcon=CCSprite:createWithSpriteFrameName("gold_pack.png")
					addIcon:setScale(0.7)
				end
				if addIcon==nil then
					addIcon=CCSprite:createWithSpriteFrameName("gold_pack.png")
					addIcon:setScale(0.7)
				end
			elseif acVo.type =="shengdanqianxi" then
				acIconUrl ="Icon_BG.png"
				if(acChrisEveVoApi and acChrisEveVoApi:getVersion() == 5)then
					addIcon=CCSprite:createWithSpriteFrameName("acSdqyV5_icon.png")
					addIcon:setScale(0.8)
				elseif(acChrisEveVoApi and acChrisEveVoApi:isNormalVersion())then
					addIcon=CCSprite:createWithSpriteFrameName("acChrisBox.png")
					addIcon:setScale(0.5)
				else
					addIcon=CCSprite:createWithSpriteFrameName("friendBtn.png")
					addIcon:setScale(0.85)
				end
			elseif acVo.type == "gangtieronglu" then
				acIconUrl = "TankLv6.png"
			elseif acVo.type == "xingyunpindian" then
				acIconUrl = "Icon_BG.png"
				addIcon=CCSprite:createWithSpriteFrameName("Dice6.png")
				addIcon:setScale(0.60)
			elseif acVo.type == "swchallengeactive" then
				acIconUrl = "sw_2.png"	
			elseif acVo.type == "xiaofeisongli" then
				acIconUrl = "resourse_normal_gem.png"
				-- addIcon=CCSprite:createWithSpriteFrameName("resourse_normal_gem.png")
				-- addIcon:setScale(0.60)
			elseif acVo.type =="ybsc" then
				acIconUrl = "IconTank_10095.png"
				if acYuebingshenchaVoApi:getVersion()==2 or acYuebingshenchaVoApi:getVersion()==4 then
					acIconUrl = "IconTank_20155.png"
				end
			elseif acVo.type =="yichujifa" then
				acIconUrl ="IconTank_10104.png"
			elseif acVo.type =="chongzhisongli" then -- 累计充值送好礼
		        acIconUrl = "resourse_normal_gem.png"
		    elseif acVo.type =="danrichongzhi" then -- 单日充值
		        acIconUrl = "resourse_normal_gem.png"
		    
		    elseif acVo.type =="danrixiaofei" then -- 单日消费
		        acIconUrl = "resourse_normal_gem.png"	
	        elseif acVo.type =="jiejingkaicai" then
				acIconUrl = "PurpleBoxRandom.png"	
			elseif acVo.type =="halloween" then
				acIconUrl = "equipBg_orange.png"
				local function firstIconClick( ... )
				end
				addIcon = LuaCCSprite:createWithSpriteFrameName("sweet_4.png",firstIconClick)
			elseif acVo.type =="xinfulaba" then
				acIconUrl = "Icon_BG.png"
				local function goldIconClick( ... )
				end
				addIcon = LuaCCSprite:createWithSpriteFrameName("GoldImage.png",goldIconClick)	
		    elseif acVo.type =="jffp" then -- 积分翻牌
		        acIconUrl ="Icon_BG.png"
				local function timeIconClick( ... )
				end
				local iconIn ="rewardCard1.png"
				addIcon = LuaCCSprite:createWithSpriteFrameName(iconIn,timeIconClick)
				addIcon:setScale(0.3)    			
			elseif acVo.type == "firstRechargenew" then
				acIconUrl = "Icon_novicePacks.png"
			elseif acVo.type == "fightRanknew" then
				acIconUrl = "Icon_BG.png"
				local function firstIconClick( ... )
				end
				addIcon = LuaCCSprite:createWithSpriteFrameName("top1.png",firstIconClick)
			elseif acVo.type == "challengeranknew" then
				acIconUrl = "Icon_BG.png"
				local function goldIconClick( ... )
				end
				addIcon = LuaCCSprite:createWithSpriteFrameName("mainBtnCheckpoint.png",goldIconClick)
			elseif acVo.type == "wanshengjiedazuozhan" then
				acIconUrl = "Icon_BG.png"
				addIcon = CCSprite:createWithSpriteFrameName("pumpkinC1.png")
				local version=acWanshengjiedazuozhanVoApi:getVersion()
				if version and version>1 then
					addIcon = CCSprite:createWithSpriteFrameName("pumpkinC1"..version..".png")
				end
				addIcon:setScale(0.6)
			elseif acVo.type =="zhanshuyantao" then
				acIconUrl = "Icon_BG.png"
				addIcon = CCSprite:createWithSpriteFrameName("serverWarTopMedal1.png")
				addIcon:setScale(0.8)
			elseif acVo.type == "yijizaitan" then
				local aid,tankID = acYijizaitanVoApi:getTankIdAndAid()
				acIconUrl = tankCfg[tankID].icon
			elseif acVo.type =="ganenjiehuikui" then
				acIconUrl ="equipBg_orange.png"
				addIcon = CCSprite:createWithSpriteFrameName("friendBtn.png")
				addIcon:setScale(0.8)
			elseif acVo.type =="christmasfight" then
				acIconUrl ="Icon_BG.png"
				if acChristmasFightVoApi:getAcShowType()==acChristmasFightVoApi.acShowType.TYPE_2 then
					addIcon = CCSprite:createWithSpriteFrameName("snowIcon_v2.png")
				else
				addIcon = CCSprite:createWithSpriteFrameName("snowIcon.png")
				end
				addIcon:setScale(0.7)
			elseif acVo.type =="mingjiangzailin" then
				acIconUrl ="Icon_novicePacks.png"
				local hid,_ =acMingjiangzailinVoApi:getHidandheroProductOrder()
				addIcon=heroVoApi:getHeroIcon(hid)
				addIcon:setScale(0.65)
			elseif acVo.type =="tankbattle" then
				acIconUrl ="Icon_BG.png"
				addIcon = CCSprite:createWithSpriteFrameName("acTankBattle_anemy2.png")
				addIcon:setScale(0.8)
			elseif acVo.type =="mingjiangzailin" then
				acIconUrl ="Icon_novicePacks.png"
				local hid,_ =acMingjiangzailinVoApi:getHidandheroProductOrder()
				addIcon=heroVoApi:getHeroIcon(hid)
				addIcon:setScale(0.65)
			elseif acVo.type =="anniversary" then
				acIconUrl ="Icon_BG.png"
				addIcon=CCSprite:createWithSpriteFrameName("AperturePhoto.png")
				addIcon:setScale(0.5)
				local tmpIcon=CCSprite:createWithSpriteFrameName("friendBtn.png")
				tmpIcon:setPosition(getCenterPoint(addIcon))
				addIcon:addChild(tmpIcon)
			elseif acVo.type =="chunjiepansheng" then
				if acVo.version ~=nil and acVo.version==3 then
					acIconUrl ="acChunjiepansheng_icon3.png"
				else
					acIconUrl ="acChunjiepansheng_icon.png"
				end
			elseif acVo.type=="smcj" then
				acIconUrl = "acSmcj_icon.png"
			elseif acVo.type=="hljb" then
				acIconUrl = "acHljb_icon.png"
			elseif acVo.type == "newyeareva" then
				acIconUrl = "Icon_BG.png"
				if acNewYearsEveVoApi:getAcShowType()==acNewYearsEveVoApi.acShowType.TYPE_2 then
					addIcon = CCSprite:createWithSpriteFrameName("t99999_1.png")
				else
				addIcon = CCSprite:createWithSpriteFrameName("t99998_1.png")
				end
				addIcon:setScale(0.1)
			elseif acVo.type =="rechargeCompetition" then
				acIconUrl ="Icon_BG.png" 
				addIcon =CCSprite:createWithSpriteFrameName("GoldImage.png")
			elseif acVo.type=="dailyEquipPlan" then
				acIconUrl ="Icon_BG.png"
				addIcon=CCSprite:createWithSpriteFrameName("equipBtn.png")
				addIcon:setScale(0.85)
			elseif acVo.type=="stormFortress" then
				acIconUrl ="Icon_BG.png"
				addIcon=CCSprite:createWithSpriteFrameName("missileIcon.png")
				addIcon:setScale(0.78)
			elseif acVo.type=="seikoStoneShop" then
				local name,pic,desc,id,noUseIdx,eType,equipId,bgname=acSeikoStoneShopVoApi:getBuyItemInfo()
				acIconUrl =bgname
				addIcon=CCSprite:createWithSpriteFrameName(pic)
				-- addIcon:setScale(0.85)
			elseif acVo.type=="anniversaryBless" then
				acIconUrl ="Icon_BG.png"
				addIcon =CCSprite:createWithSpriteFrameName("ac_bless_icon.png")
				addIcon:setScale(0.78)
			elseif acVo.type=="blessingWheel" then
				acIconUrl ="Icon_BG.png"
				addIcon =CCSprite:createWithSpriteFrameName("bless_rotary_icon.png")
				addIcon:setScale(0.78)
			elseif acVo.type=="monthlysign" then
				acIconUrl="monthlysignIcon.png"
			elseif acVo.type=="rechargebag" then
				acIconUrl ="can_gift_red_packets.png"
			elseif acVo.type=="benfuqianxian" then
				acIconUrl ="satellite.png"
			elseif acVo.type=="aoyunjizhang" then
				acIconUrl="olympicIcon.png"
			elseif acVo.type=="battleplane" then
				acIconUrl="acAntiAirIcon.png"
			elseif acVo.type=="mingjiangpeiyang" then
				acIconUrl="Icon_novicePacks.png"
				local mustgetHero=acMingjiangpeiyangVoApi:mustGetHero()
                local hid,heroProductOrder=acMingjiangpeiyangVoApi:getHidandheroProductOrder(mustgetHero)
                if hid and heroProductOrder then
					addIcon=heroVoApi:getHeroIcon(hid)
					addIcon:setScale(0.65)
                end
            elseif acVo.type=="midautumn" then
            	acIconUrl=acMidAutumnVoApi:getVersion() == 3 and "acMidAutumn2Icon.png" or "acmidautumn_icon.png"
        	elseif acVo.type=="threeyear" then
				acIconUrl="Icon_BG.png"
				addIcon=CCSprite:createWithSpriteFrameName("threeyear_icon.png")
				addIcon:setScale(0.25)
			elseif acVo.type=="zhanyoujijie" then
				acIconUrl="Icon_BG.png"
				addIcon=CCSprite:createWithSpriteFrameName("mainBtnFriend.png")
				addIcon:setScale(0.8)
			elseif acVo.type=="mineExplore" then
				acIconUrl="equipBg_purple.png"
				addIcon=CCSprite:createWithSpriteFrameName("maze_diamond.png")
				addIcon:setScale(0.9)
			elseif acVo.type=="mineExploreG" then
				acIconUrl="equipBg_purple.png"
				addIcon=CCSprite:createWithSpriteFrameName("maze_diamond.png")
				-- addIcon:setScale(0.9)
			elseif acVo.type=="wdyo" then
				acIconUrl="acTxj_icon.png"
			elseif acVo.type=="christmas2016" then
            	acIconUrl="christmas2016Icon.png"
            elseif acVo.type=="djrecall" then
            	acIconUrl="heroManage.png"
        	elseif acVo.type=="cjyx" then
				acIconUrl="acCjyx_icon.png"
			elseif acVo.type=="yswj" then
				acIconUrl="acyswj_icon.png"
			elseif acVo.type=="zjfb" then
				acIconUrl="acZjfb_icon.png"
			elseif acVo.type=="ljcz" then
				acIconUrl="Icon_BG.png"
				addIcon=CCSprite:createWithSpriteFrameName("iconGoldNew6.png")
				addIcon:setScale(0.7)
			elseif acVo.type=="ljcz3" then
				acIconUrl="Icon_BG.png"
				addIcon=CCSprite:createWithSpriteFrameName("iconGoldNew6.png")
				addIcon:setScale(0.7)
			elseif acVo.type=="sdzs" then
				acIconUrl="serverWarLocalIcon.png"
			elseif acVo.type=="ramadan" then
				acIconUrl="Icon_BG.png"
				addIcon=CCSprite:createWithSpriteFrameName("ramadanHead.png")
				addIcon:setScale(70/addIcon:getContentSize().width)
			elseif acVo.type=="phlt" then
				acIconUrl="acPhlt_icon.png"
			elseif acVo.type=="hxgh" then
				acIconUrl="achxgh_icon.png"
			elseif acVo.type=="zzrs" then
				acIconUrl="acThriving_icon.png"
			elseif acVo.type=="kljz" then
				acIconUrl="acKljz_icon.png"
			elseif acVo.type=="fuyunshuangshou" then
				acIconUrl="acFyss_icon.png"
			elseif acVo.type=="znkh" then
				if acZnkhVoApi and acZnkhVoApi:getVersion()==3 then
					acIconUrl="acZnkh_icon_3.png"
				else
					acIconUrl="acZnkh_icon.png"
				end
			elseif acVo.type=="lmqrj" then
				if acLmqrjVoApi and acLmqrjVoApi:getVersion()==2 then
					acIconUrl="acLmqrj_icon_v2.png"
				else
					acIconUrl="acLmqrj_icon.png"
				end
			elseif acVo.type == "thfb" then
				acIconUrl="thfb_icon.png"
			elseif acVo.type == "xcjh" then
				if acXcjhVoApi and acXcjhVoApi:getVersion()==2 then
					acIconUrl="acXcjhIcon_v2.png"
				else
					acIconUrl="acXcjhIcon.png"
				end
			elseif acVo.type == "mjzy" then
				acIconUrl="acMjzy_icon.png"
			elseif acVo.type == "xlys" then
				acIconUrl="xlysIcon.png"
			elseif acVo.type=="ydcz" then
				acIconUrl="ydczicon.png"
			elseif acVo.type=="tqbj" then
				acIconUrl="acTqbjIcon.png"
			elseif acVo.type=="xstq" then
				acIconUrl="acTqbjIcon.png" 
			elseif acVo.type == "smbd" then
				acIconUrl = "smbd_icon.png"
			elseif acVo.type == "hryx" then
				acIconUrl = "acWxgxIcon.png"
				local iconUrl = acHryxVoApi:getAddIcon()
				addIcon = CCSprite:createWithSpriteFrameName(iconUrl)
			elseif acVo.type == "wxgx" then
				acIconUrl = "acWxgxIcon.png"
				local iconUrl = acWxgxVoApi:getAddIcon()
				addIcon = CCSprite:createWithSpriteFrameName(iconUrl)
			elseif acVo.type == "ryhg" then
				acIconUrl = "acRyhgIcon.png"
			elseif acVo.type=="znjl" then
				if acZnjlVoApi and acZnjlVoApi:getVersion() == 1 then
					acIconUrl = "acznjl_icon.png"
				else
					acIconUrl = "acJnsd_icon.png"
				end
			elseif acVo.type == "znkh2018" then
				acIconUrl = "acZnkh2018.png"
			elseif acVo.type == "kfcz" then
				acIconUrl = "acKfcz_icon.png"
			elseif acVo.type == "zntp" then
				acIconUrl = "acZntp_icon.png"
			elseif acVo.type == "jtxlh" then
				acIconUrl = "acJtxlh_icon.png"
			elseif acVo.type == "znkh2019" then
				acIconUrl = "acZnkh19_icon.png"
			elseif acVo.type == "hjld" then
				acIconUrl = "acMemoryServer_icon.png"
			elseif acVo.type == "xjlb" then
				acIconUrl = "Icon_BG.png"
				addIcon = CCSprite:createWithSpriteFrameName(acCashGiftBagVoApi:getIconImage())
				addIcon:setScale(65 / addIcon:getContentSize().width)
			else
				local arr=Split(acVo.type,"_")
				if arr[1]=="buyreward" then
					if acVo.type=="buyreward_33" or acVo.type=="buyreward_35" then
						acIconUrl="Icon_BG.png"
						local iconName=acBuyrewardVoApi:getAcIcon(acVo.type) .. ".png"
						addIcon=CCSprite:createWithSpriteFrameName(iconName)
						addIcon:setScale(0.8)
					else
						acIconUrl = acBuyrewardVoApi:getAcIcon(acVo.type) .. ".png"
					end
				elseif arr[1]=="pjjnh" then
					-- Icon_BG.png
					acIconUrl = "Icon_BG.png"
					addIcon =CCSprite:createWithSpriteFrameName("mainBtnAccessory_Down.png")
					addIcon:setScale(0.78)
				elseif arr[1] =="olympic" then
					acIconUrl = "olympicIcon.png"
				elseif arr[1]=="luckcard" then
					local picName = acLuckyPokerVoApi:getBigRewardTb(acVo.type).pic
					acIconUrl = picName
				elseif arr[1] == "customLottery" then
					acIconUrl = "ShadowTank.png"
				elseif arr[1] == "gqkh" then
					acIconUrl = "acGqkh_icon.png"
				elseif arr[1] == "wsjdzz2017" then
					acIconUrl = "Icon_BG.png"
					acWsjdzzIIVoApi:setActiveName(acVo.type)
					if acWsjdzzIIVoApi:getVersion() == 2 or acWsjdzzIIVoApi:getVersion() == 4 then
						addIcon = CCSprite:createWithSpriteFrameName("taskBox5.png")
					elseif acWsjdzzIIVoApi:getVersion() == 1 then
						addIcon = CCSprite:createWithSpriteFrameName("pumpkinIIC1.png")
					elseif acWsjdzzIIVoApi:getVersion() == 3 then
						addIcon = CCSprite:createWithSpriteFrameName("pop_plane_icon.png")
					end
					addIcon:setScale(0.7)
				elseif arr[1] == "wsjdzz" then
					acIconUrl = "Icon_BG.png"
					if(acWsjdzzVoApi and acWsjdzzVoApi:isNormalVersion(acVo.type))then
						addIcon = CCSprite:createWithSpriteFrameName("taskBox5.png")
					else
						addIcon = CCSprite:createWithSpriteFrameName("pumpkinC1.png")
					end
					addIcon:setScale(0.6)
				elseif arr[1] == "openyear" then
					acIconUrl = "openyear_icon.png"
					-- addIcon = CCSprite:createWithSpriteFrameName("openyear_common_fd.png")
				elseif arr[1] == "btzx" then
					acIconUrl = "acBtzx_icon.png"
				elseif arr[1] == "gej2016" then
					acIconUrl = "acGej2016_icon.png"
				elseif arr[1] == "nljj" then
					acIconUrl = "acNljj_icon.png"
				elseif arr[1] == "qxtw" then
					local key=acQxtwVoApi:getGetKey(acVo.type)
					local equipCfg = emblemVoApi:getEquipCfgById(key)
		            acIconUrl="active_common_icon.png"
		            addIcon=emblemVoApi:getEquipIconNoBg(key)
		            addIcon:setScale(90/addIcon:getContentSize().width)
	            elseif arr[1] == "xscj" then
		            acIconUrl = "Icon_zhu_ji_di.png"
	            elseif arr[1] == "zjjz" then
		            acIconUrl = "armorMatrix_icon.png"
	            elseif arr[1] == "xssd" then
					acIconUrl ="Icon_BG.png"
					addIcon=CCSprite:createWithSpriteFrameName("friendBtn.png")
					addIcon:setScale(0.7)
				elseif arr[1] == "wjdc" then
					acIconUrl ="Icon_BG.png"
					addIcon=CCSprite:createWithSpriteFrameName("acWjdcIcon.png")
					addIcon:setScale(0.7)
				elseif arr[1] == "znkh2017" then
					-- acIconUrl ="acZnkh2017_icon.png"
					acIconUrl="Icon_BG.png"
					addIcon=CCSprite:createWithSpriteFrameName("threeyear_vipicon.png")
					addIcon:setScale(78/addIcon:getContentSize().width)
				elseif arr[1] == "pjgx" then
					acIconUrl="acPjgx_icon.png"
				elseif arr[1] == "tccx" then
					acIconUrl="acTccx_icon.png"
				elseif arr[1] == "wmzz" then
					acIconUrl="acWmzz_icon.png"
				elseif arr[1] == "yjtsg" then
					acIconUrl=acYjtsgVoApi:getActivityIcon(acVo.type)
				elseif arr[1] == "gzhx" then
					acIconUrl=acGzhxVoApi:getActivityIcon(acVo.type)
				elseif arr[1] == "cjms" then
					acIconUrl="acCjms_icon.png"
				elseif arr[1] == "zjjy" then
					acIconUrl="acArmorElite_icon.png"
				elseif arr[1] == "kzhd" then
					acIconUrl="acKzhd_icon.png"
				elseif arr[1] == "khzr" then
					acIconUrl="acKzhd_icon.png"
				elseif arr[1] == "znqd2017" then
					acIconUrl="acznqd2017Icon.png"
				elseif arr[1] == "secretshop" then
					acIconUrl="acSecretshop_icon.png"
				elseif arr[1] =="qmcj" then
					acIconUrl="acQmcj_icon.png"
				elseif arr[1] =="qmsd" then
					acIconUrl ="acQmsd_icon.png"
				elseif arr[1] =="mjzx" then
					acIconUrl ="acMjzx_icon.png"
				elseif arr[1] =="yrj" then
					if acYrjVoApi:getVersion() == 1 then
						acIconUrl ="acYrj_icon.png"
					elseif acYrjVoApi:getVersion() == 2 then
						acIconUrl ="lucky_star_icon.png"
					end
				elseif arr[1] =="duanwu" then
					if acDuanWuVoApi:getVersion() == 1 then
						acIconUrl="acDuanWu_icon.png"
					else
						acIconUrl="acDuanWu2_icon.png"
					end
				elseif arr[1] == "wpbd" then
					acIconUrl="acWpbdIcon.png"
				elseif arr[1] == "dlbz" then
					acIconUrl="acDlbz_icon.png"
				elseif arr[1] == "czhk" then
					acIconUrl="acCzhk_icon.png"
				elseif arr[1] == "bhqf" then
					acIconUrl="acBhqf_icon.png"
				elseif arr[1] == "cflm" then
					acIconUrl="acCflmIcon.png"
				elseif arr[1] == "gwkh" then
					acIconUrl = "acGwkh_icon.png"
				elseif arr[1] == "mjcs" then
					acIconUrl = "acMjcs_icon.png"
				elseif arr[1] == "zncf" then
					acIconUrl = "acZncfIcon.png"
				elseif arr[1] == "xlpd" then
					acIconUrl = "acXlpd_icon.png"
				elseif arr[1] == "xssd2019" then
					acIconUrl = "acXssd2019_icon.png"
				elseif arr[1]=="wsj2018" then--acWsj2018_icon
					local version = acHalloween2018VoApi:getVersion()
					if version==2 then
						acIconUrl = "acWsj2018_icon_ver2.png"
					else
						acIconUrl = "acWsj2018_icon.png"
					end
				elseif arr[1] == "jblb" then
					acIconUrl = "Icon_BG.png"
					addIcon = CCSprite:createWithSpriteFrameName(acCustomVoApi:getIconImage(arr[2]))
					addIcon:setScale(65 / addIcon:getContentSize().width)
				elseif arr[1] == "jjzz" then
					acIconUrl = "ac_jjzz_icon.png"
				elseif arr[1] == "nlgc" then
					acIconUrl = "Icon_BG.png"
					addIcon = CCSprite:createWithSpriteFrameName("ac_nlgc_icon.png")
					addIcon:setScale(65 / addIcon:getContentSize().width)
				else
					acIconUrl = "Icon_novicePacks.png"
				end
			end

			local strSize1=24
			local strSize2=20
			if (acVo.type == "firstRechargenew" or acVo.type == "firstRecharge") and G_getCurChoseLanguage() =="de" then
				strSize1=20
				strSize2=18
			end
			if acVo.type == "mjcs" then
				if G_isAsia() == false then
					strSize1 = 18
				end
			end

			local acNameLabel=GetTTFLabelWrap(acName,strSize1,CCSizeMake(backSprie:getContentSize().width - 210, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,"Helvetica-bold")
			acNameLabel:setAnchorPoint(ccp(0,1))
			acNameLabel:setPosition(ccp(labelX, bgH - 30))
			acNameLabel:setColor(G_ColorYellowPro)
			backSprie:addChild(acNameLabel,5)
			local timeStr=activityVoApi:getAcListShowTime(acVo)
			if acVo.type=="ydcz" and acYdczVoApi then
				timeStr=acYdczVoApi:getTimeStr()
			end
			local timeStrPosY = 50
			local languageTb = {cn=1,ko=1,ja=1,tw=1}
			if languageTb[G_getCurChoseLanguage()] == nil then
				if acVo.type == "firstRecharge" then
					timeStrPosY = 50
				end
			end
			local acTime=GetTTFLabelWrap(timeStr,strSize2,CCSizeMake(350,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
			acTime:setAnchorPoint(ccp(0,0.5))
			acTime:setPosition(ccp(labelX,timeStrPosY))
			backSprie:addChild(acTime,6)
			if acVo.type == "hjld" then
				acTime:setVisible(false)
			end

			if (acVo.type == "firstRechargenew" or acVo.type == "firstRecharge") and G_getCurChoseLanguage() =="de" then
				acNameLabel:setPosition(ccp(labelX, bgH - 20))
				acTime:setPosition(ccp(labelX,timeStrPosY-10))
			elseif G_getCurChoseLanguage() =="fr" then
				if acVo.type == "kljz" then
					acTime:setPositionY(timeStrPosY-10)
				end
			end


			if self.lbTab==nil then
				self.lbTab={}
			end

			if self.lbTab then
				self.lbTab[idx+1]={lb=acTime,vo=acVo}
			end
			if self.nhtimeTb==nil then
				self.nhtimeTb={}
			end
			if acVo.type=="ydcz" then --月度充值活动时间特殊处理
				self.nhtimeTb[acVo.type]={lb=acTime}
			end

			if acVo.type=="growingPlan" then
				addFlicker = true
			end
			if acVo and acVo.canRewardFlag == true then
				local flicker = self:getIconFlicker(menuItemDesc,0.8,0.8)
				flicker:setVisible(true)
			end
			isNew = activityVoApi:checkIfIsNew(acVo.type)
			activityVoApi:afterShowState(acVo)
		elseif self.selectedTabIndex==1 then
			dailyActivityVoApi:sortActivity()
			local acVo=dailyActivityVoApi:getAllActivity()[idx + 1]
			local timeStr=""
			if(acVo.type=="rpShop")then
				acName=getlocal("rpshop_title")
				acIconUrl = "Icon_BG.png"
				addIcon = CCSprite:createWithSpriteFrameName("rpCoin.png")
				addIcon:setScale(0.5)
				-- timeStr=getlocal("serverwar_opentime",{getlocal("rpshop_openTime")})
				timeStr=dailyActivityVoApi:getTimeStr(true)
			elseif acVo.type=="drew1" then
				acName=getlocal("dailyActivity_receivereward_title1")
				acIconUrl = "Icon_BG.png"
				addIcon = CCSprite:createWithSpriteFrameName("energyIcon.png")
				addIcon:setScale(2)
				timeStr=receivereward1VoApi:getTimeStr()
				
			elseif (acVo.type=="drew2") then
				acName=getlocal("dailyActivity_receivereward_title2")
				acIconUrl = "Icon_BG.png"
				addIcon = CCSprite:createWithSpriteFrameName("energyIcon.png")
				addIcon:setScale(2)
				timeStr=receivereward2VoApi:getTimeStr()
			elseif(acVo.type=="dailychoice")then
				acName=getlocal("dailyAnswer_title")
				-- acIconUrl = "mainBtnHelp.png"
				acIconUrl = "Icon_BG.png"
				addIcon = CCSprite:createWithSpriteFrameName("mainBtnHelp.png")
				addIcon:setScale(0.8)
				local time1 = string.format("%02d:%02d",acVo.st[1],acVo.st[2])
				local time2 = string.format("%02d:%02d",acVo.et[1],acVo.et[2])
				timeStr = string.format("%s~%s",time1,time2)
			-- 天天基金	
			elseif(acVo.type == "ttjj") then
				acName = getlocal("activity_ttjj_title")
				acIconUrl = "ttjjIcon.png"
			elseif(acVo.type == "xstz") then
				acName = getlocal("limitNormalChanllenge")
				acIconUrl = "normalChallengeIcon.png"
			elseif(acVo.type == "xstzh") then
				acName = getlocal("limitHellChanllenge")
				acIconUrl = "hellChallengeIcon.png"
			elseif(acVo.type == "ydhk") then
				acName = getlocal("daily_ydhk_title")
				acIconUrl = "ydhk_icon.png"
				if dailyYdhkVoApi then
					timeStr = dailyYdhkVoApi:getTimeStr()
				end
			elseif(acVo.type=="dailyLottery")then
				acName=getlocal("dailyActivity_lottery_title")
				acIconUrl = "item_baoxiang_09.png"
				timeStr=dailyActivityVoApi:getTimeStr()
			elseif(acVo.type=="isSignSwitch")then
				acName=getlocal("dailyActivity_sign_title")
				acIconUrl = "30dayIcon.png"
				timeStr=dailyActivityVoApi:getTimeStr()
			elseif(acVo.type=="dnews")then
				acName=getlocal("dailyNews_title")
				acIconUrl = "dailyNews_icon.png"
				timeStr=dailyActivityVoApi:getTimeStr()
			elseif(acVo.type=="movgaBind")then
				acName=getlocal("activity_movgaBind_title")
				acIconUrl = "Icon_novicePacks.png"
				timeStr=""
			end
            if(acVo.type=="boss")then
				acName=getlocal("BossBattle_title")
				acIconUrl = "bossIcon.png"
                if acVo.st and acVo.et then
                    --local startTime,endTime =BossBattleVoApi:getBossOpenTime()
					-- timeStr=getlocal("activity_time",{G_getTimeStr(acVo.st-G_getWeeTs(acVo.st)), G_getTimeStr(acVo.et-G_getWeeTs(acVo.et))})
                	timeStr=dailyActivityVoApi:getTimeStr(nil,acVo.st,acVo.et)
                else
                    timeStr=""
                end

			end
			if G_isGlobalServer()==true then
				local tStr=G_getDailyActivityTimeShow(acVo)
				if tStr and tStr~="" then
					timeStr=tStr
				end
			end

			if base.dailyAcYouhuaSwitch==1 then
				backSprie=GetButtonItem("acItemBg1.png","acItemBg2.png","acItemBg2.png",cellClick,idx,nil,nil,nil,CCRect(40,40,10,10),CCSizeMake(G_VisibleSizeWidth - 40,bgH+4))
				local bgMenu=CCMenu:createWithItem(backSprie)
				bgMenu:setTouchPriority(-(self.layerNum-1)*20-2)
				cell:addChild(bgMenu,1)
				backSpriteCenterY=backSprie:getContentSize().height/2
				bgMenu:setPosition(ccp(backSprie:getContentSize().width/2-5,backSpriteCenterY))
				menuDesc:setPosition(ccp(backSprie:getContentSize().width - 30, backSpriteCenterY))
			else
			backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),cellClick)
			backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth - 60, bgH))
			backSprie:setAnchorPoint(ccp(0,0))
			backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
			cell:addChild(backSprie,1)
			backSpriteCenterY = backSprie:getContentSize().height/2
			menuDesc:setPosition(ccp(backSprie:getContentSize().width - 30, backSpriteCenterY))
				backSprie:setPosition(ccp(5,0))
			end
			local acNameLabel=GetTTFLabelWrap(acName,24,CCSizeMake(backSprie:getContentSize().width - 220, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,"Helvetica-bold")
			acNameLabel:setAnchorPoint(ccp(0,1))
			acNameLabel:setPosition(ccp(labelX, bgH - 30))
			acNameLabel:setColor(G_ColorYellowPro)
			backSprie:addChild(acNameLabel,5)
			local strSize2 = 24
			local acTimePosY = 50
			if(acVo.type=="rpShop") and G_getCurChoseLanguage() =="ru" then
				strSize2 = 20
				acTimePosY = 50
			end
			local acTime=GetTTFLabelWrap(timeStr,20,CCSizeMake(350,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
			acTime:setAnchorPoint(ccp(0,0.5))
			acTime:setPosition(ccp(labelX, acTimePosY))
			backSprie:addChild(acTime,6)

			if acVo.type == "xstz" or  acVo.type == "xstzh" then
				if acVo.type == "xstz" then
					-- 拉一次数据
					local function callback(fn,data)
						local ret,sData = base:checkServerData(data)
						if ret==true then  
							if sData and sData.data and sData.data.limittask then
								limitChallengeVoApi:updateData(sData.data.limittask)
								
							end
						end
					end
					socketHelper:xstzGetTask(callback)
				end
				local acTime=GetTTFLabelWrap(limitChallengeVoApi:getTimeStr(),20,CCSizeMake(350,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
				acTime:setAnchorPoint(ccp(0,0.5))
				acTime:setPosition(ccp(labelX, acTimePosY))
				backSprie:addChild(acTime,7)
				self.refreshTimeTb[acVo.type] = acTime
			end

			if self.dailyLbTab==nil then
				self.dailyLbTab={}
			end
			self.dailyLbTab[idx+1]={lb=acTime,vo=acVo}
			
			
			if base.dailyAcYouhuaSwitch==1 then
				local canReward=false
				if acVo.type=="dailyLottery" then
					if dailyVoApi and dailyVoApi:isFree()==true then
						canReward=true
					end
				elseif(acVo.type=="isSignSwitch")then
					if base.newSign == 1 then

						if newSignInVoApi and newSignInVoApi:isToday()==false then
							canReward=true
						end
					else
						if signVoApi and signVoApi:isTodaySign()==false then
							canReward=true
						end
					end
				elseif acVo.canReward and acVo:canReward()==true then
					canReward=true
				elseif acVo.checkActive and acVo:checkActive()==true then
					canReward=true
		        end
		        if canReward==true then
		        	isNew = true
		        	-- if base.dailyAcYouhuaSwitch==1 then
		        		local mx=backSprie:getContentSize().width/2
		        		local opacity=50
		        		local actTime=0.6
			            local function showAnimation()
				            local lightSp1=CCSprite:createWithSpriteFrameName("acItemlight.png")
				            local px,py=0-lightSp1:getContentSize().width/2,lightSp1:getContentSize().height/2
				            lightSp1:setPosition(ccp(px,backSprie:getContentSize().height-py))
				            backSprie:addChild(lightSp1,10)
				            lightSp1:setOpacity(opacity)
				            local lightSp2=CCSprite:createWithSpriteFrameName("acItemlight.png")
				            lightSp2:setPosition(ccp(px,py))
				            backSprie:addChild(lightSp2,10)
				            lightSp2:setOpacity(opacity)

				            local function callBack1()
				            	lightSp1:setVisible(false)
				            end
				            local function callBack2()
				            	lightSp2:setVisible(false)
				            end
				            local function callBack3()
				            	lightSp1:setVisible(true)
				            	lightSp1:setPosition(ccp(px,backSprie:getContentSize().height-py))
				            end
				            local function callBack4()
				            	lightSp2:setVisible(true)
				            	lightSp2:setPosition(ccp(px,py))
				            end
				            local moveTo1=CCMoveTo:create(actTime,ccp(mx,backSprie:getContentSize().height-py))
				            local moveTo2=CCMoveTo:create(actTime,ccp(mx,py))
				            local fadeTo1=CCFadeTo:create(actTime,255)
				            local carray1=CCArray:create()
							carray1:addObject(moveTo1)
							carray1:addObject(fadeTo1)
							local spawn1=CCSpawn:create(carray1)
							local carray2=CCArray:create()
							carray2:addObject(moveTo2)
							carray2:addObject(fadeTo1)
							local spawn2=CCSpawn:create(carray2)
							local moveTo3=CCMoveTo:create(actTime,ccp(backSprie:getContentSize().width-px,backSprie:getContentSize().height-py))
							local moveTo4=CCMoveTo:create(actTime,ccp(backSprie:getContentSize().width-px,py))
							local fadeTo2=CCFadeTo:create(actTime,opacity)
							local carray3=CCArray:create()
							carray3:addObject(moveTo3)
							carray3:addObject(fadeTo2)
							local spawn3=CCSpawn:create(carray3)
							local carray4=CCArray:create()
							carray4:addObject(moveTo4)
							carray4:addObject(fadeTo2)
							local spawn4=CCSpawn:create(carray4)
							local callFunc1=CCCallFunc:create(callBack1)
							local callFunc2=CCCallFunc:create(callBack2)
							local callFunc3=CCCallFunc:create(callBack3)
							local callFunc4=CCCallFunc:create(callBack4)

							local delay1=CCDelayTime:create(0.2)
							local acArr1=CCArray:create()
							acArr1:addObject(spawn1)
							acArr1:addObject(spawn3)
							acArr1:addObject(callFunc1)
							acArr1:addObject(delay1)
							acArr1:addObject(callFunc3)
							local acArr2=CCArray:create()
							acArr2:addObject(spawn2)
							acArr2:addObject(spawn4)
							acArr2:addObject(callFunc2)
							acArr2:addObject(delay1)
							acArr2:addObject(callFunc4)
							local seq1=CCSequence:create(acArr1)
							local seq2=CCSequence:create(acArr2)
							lightSp1:runAction(CCRepeatForever:create(seq1))
							lightSp2:runAction(CCRepeatForever:create(seq2))
						end
						showAnimation()
						local acArr=CCArray:create()
						local delay=CCDelayTime:create(0.6)
						local callFunc=CCCallFunc:create(showAnimation)
						acArr:addObject(delay)
	                    acArr:addObject(callFunc)
	                    local seq=CCSequence:create(acArr)
	                    backSprie:runAction(seq)
			        -- end
		        end
			else
				if(acVo:canReward())then
					local flicker = self:getIconFlicker(menuItemDesc,0.8,0.8)
					flicker:setVisible(true)
				end
			end
			

			if acVo.type=="drew1" then
				self.menuItemDesc1=menuItemDesc
			end

			if acVo.type=="drew2" then
				self.menuItemDesc2=menuItemDesc
			end
		else
			-- 新闻
			local note = noteVoApi:getAllNote()[idx + 1]
			acIconUrl = "acAndNote.png"
			if base.dailyAcYouhuaSwitch==1 then
				backSprie=GetButtonItem("acItemBg1.png","acItemBg2.png","acItemBg2.png",cellClick,idx,nil,nil,nil,CCRect(40,40,10,10),CCSizeMake(G_VisibleSizeWidth - 40,bgH+4))
				local bgMenu=CCMenu:createWithItem(backSprie)
				bgMenu:setTouchPriority(-(self.layerNum-1)*20-2)
				cell:addChild(bgMenu,1)
				backSpriteCenterY=backSprie:getContentSize().height/2
				bgMenu:setPosition(ccp(backSprie:getContentSize().width/2-5,backSpriteCenterY))
				menuDesc:setPosition(ccp(backSprie:getContentSize().width - 30, backSpriteCenterY))
		        if note.read == false then
		        	isNew = true
					local mx=backSprie:getContentSize().width/2
					local opacity=50
					local actTime=0.6
					local function showAnimation()
						local lightSp1=CCSprite:createWithSpriteFrameName("acItemlight.png")
						local px,py=0-lightSp1:getContentSize().width/2,lightSp1:getContentSize().height/2
						lightSp1:setPosition(ccp(px,backSprie:getContentSize().height-py))
						backSprie:addChild(lightSp1,10)
						lightSp1:setOpacity(opacity)
						local lightSp2=CCSprite:createWithSpriteFrameName("acItemlight.png")
						lightSp2:setPosition(ccp(px,py))
						backSprie:addChild(lightSp2,10)
						lightSp2:setOpacity(opacity)
						local function callBack1()
							lightSp1:setVisible(false)
						end
						local function callBack2()
							lightSp2:setVisible(false)
						end
						local function callBack3()
							lightSp1:setVisible(true)
							lightSp1:setPosition(ccp(px,backSprie:getContentSize().height-py))
						end
						local function callBack4()
							lightSp2:setVisible(true)
							lightSp2:setPosition(ccp(px,py))
						end
						local moveTo1=CCMoveTo:create(actTime,ccp(mx,backSprie:getContentSize().height-py))
						local moveTo2=CCMoveTo:create(actTime,ccp(mx,py))
						local fadeTo1=CCFadeTo:create(actTime,255)
						local carray1=CCArray:create()
						carray1:addObject(moveTo1)
						carray1:addObject(fadeTo1)
						local spawn1=CCSpawn:create(carray1)
						local carray2=CCArray:create()
						carray2:addObject(moveTo2)
						carray2:addObject(fadeTo1)
						local spawn2=CCSpawn:create(carray2)
						local moveTo3=CCMoveTo:create(actTime,ccp(backSprie:getContentSize().width-px,backSprie:getContentSize().height-py))
						local moveTo4=CCMoveTo:create(actTime,ccp(backSprie:getContentSize().width-px,py))
						local fadeTo2=CCFadeTo:create(actTime,opacity)
						local carray3=CCArray:create()
						carray3:addObject(moveTo3)
						carray3:addObject(fadeTo2)
						local spawn3=CCSpawn:create(carray3)
						local carray4=CCArray:create()
						carray4:addObject(moveTo4)
						carray4:addObject(fadeTo2)
						local spawn4=CCSpawn:create(carray4)
						local callFunc1=CCCallFunc:create(callBack1)
						local callFunc2=CCCallFunc:create(callBack2)
						local callFunc3=CCCallFunc:create(callBack3)
						local callFunc4=CCCallFunc:create(callBack4)

						local delay1=CCDelayTime:create(0.2)
						local acArr1=CCArray:create()
						acArr1:addObject(spawn1)
						acArr1:addObject(spawn3)
						acArr1:addObject(callFunc1)
						acArr1:addObject(delay1)
						acArr1:addObject(callFunc3)
						local acArr2=CCArray:create()
						acArr2:addObject(spawn2)
						acArr2:addObject(spawn4)
						acArr2:addObject(callFunc2)
						acArr2:addObject(delay1)
						acArr2:addObject(callFunc4)
						local seq1=CCSequence:create(acArr1)
						local seq2=CCSequence:create(acArr2)
						lightSp1:runAction(CCRepeatForever:create(seq1))
						lightSp2:runAction(CCRepeatForever:create(seq2))
					end
					showAnimation()
					local acArr=CCArray:create()
					local delay=CCDelayTime:create(0.6)
					local callFunc=CCCallFunc:create(showAnimation)
					acArr:addObject(delay)
					acArr:addObject(callFunc)
					local seq=CCSequence:create(acArr)
					backSprie:runAction(seq)
				else
					isNew=false
		        end
			else
				if note.read == true then
					isNew = false
					backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),cellClick)
				else
					isNew = true
					backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("letterBgNoRead.png",CCRect(20, 20, 10, 10),cellClick)
				end
				backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth - 60, bgH))
				backSprie:setAnchorPoint(ccp(0,0))
				backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
				cell:addChild(backSprie,1)
				backSpriteCenterY = backSprie:getContentSize().height/2
				menuDesc:setPosition(ccp(backSprie:getContentSize().width - 30, backSpriteCenterY))
				backSprie:setPosition(ccp(5,0))
			end

			local noteTitle = GetTTFLabelWrap(note.title,24,CCSizeMake(backSprie:getContentSize().width - 180, 60),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,"Helvetica-bold")
			noteTitle:setAnchorPoint(ccp(0,1))
			noteTitle:setColor(G_ColorYellowPro)
			noteTitle:setPosition(ccp(labelX, bgH - 30))
			backSprie:addChild(noteTitle,5)

			local dateLabel = GetTTFLabel(G_getDataTimeStr(note.st,true),20)
			dateLabel:setAnchorPoint(ccp(0,0))
			dateLabel:setPosition(ccp(labelX, 30))
			backSprie:addChild(dateLabel,6)
		end
		local acIcon = CCSprite:createWithSpriteFrameName(acIconUrl)
		if acIcon==nil then
			acIcon = CCSprite:createWithSpriteFrameName("Icon_BG.png")
			local heroImageStr ="ship/Hero_Icon/"..acIconUrl
			if platCfg.platCfgHeroCartoonPhoto[G_curPlatName()]~=nil then
				heroImageStr ="ship/Hero_Icon_Cartoon/"..acIconUrl
			end
			addIcon=CCSprite:create(heroImageStr)
			if addIcon then
				addIcon:setScale(70/addIcon:getContentSize().width)
			end
		end
		acIcon:setScale(100 / acIcon:getContentSize().width)
		if addFlicker == true then
			local rectFlicker=G_addRectFlicker(acIcon, 1.3, 1.3)
			rectFlicker:setVisible(true)
		end
		if addIcon ~= nil then
			local acVo=activityVoApi:getAllActivity()[idx + 1]
			if acVo and acVo.type=="ramadan" then
				addIcon:setPosition(acIcon:getContentSize().width/2,acIcon:getContentSize().height/2+0.5)
			else
				addIcon:setPosition(getCenterPoint(acIcon))
			end
			acIcon:addChild(addIcon,1)
		end
		if addIcon2 then
			addIcon2:setPosition(getCenterPoint(acIcon))
			acIcon:addChild(addIcon2,1)
		end

		acIcon:setPosition(ccp(70, backSpriteCenterY))
		backSprie:addChild(acIcon,4)
    
    	if isNew == true then
			local numHeight=25
			local iconWidth=36
			local iconHeight=36
			local newsNumLabel = GetTTFLabel("1",numHeight)
			local capInSet1 = CCRect(17, 17, 1, 1)
			local function touchClick()
			end
			local newsIcon =LuaCCScale9Sprite:createWithSpriteFrameName("NumBg.png",capInSet1,touchClick)
			if newsNumLabel:getContentSize().width+10>iconWidth then
				iconWidth=newsNumLabel:getContentSize().width+10
			end
			newsIcon:setContentSize(CCSizeMake(iconWidth,iconHeight))
			newsIcon:ignoreAnchorPointForPosition(false)
			newsIcon:setAnchorPoint(CCPointMake(0.5,0.5))
			newsIcon:setPosition(ccp(35,bgH - iconHeight/2 - 15))
			newsIcon:addChild(newsNumLabel,1)
			newsNumLabel:setPosition(getCenterPoint(newsIcon))
			backSprie:addChild(newsIcon,6)
		end

		backSprie:addChild(menuDesc,1)
		return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded" then
	end
end

--点击tab页签 idx:索引
function activityAndNoteDialog:tabClick(idx)
    if newGuidMgr:isNewGuiding()==true then
        do
          return
        end
    end
    PlayEffect(audioCfg.mouseClick)
    if idx~=1 then
    	self.menuItemFlag1=false
    	self.menuItemFlag2=false
    end
    for k,v in pairs(self.allTabs) do
      if v:getTag()==idx then
        v:setEnabled(false)
        self.selectedTabIndex=idx

        self:getDataByType(idx+1)
      else
        v:setEnabled(true)
      end
    end
end

-- 点击打开活动按钮，弹出活动面板
function activityAndNoteDialog:openInfo(tag)
	-- if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
		-- if newGuidMgr:isNewGuiding()==true or G_checkClickEnable()==false then
		if newGuidMgr:isNewGuiding()==true then
			do return end
		end
		PlayEffect(audioCfg.mouseClick)
		if self.selectedTabIndex==0 then
			local acVo=activityVoApi:getAllActivity()[tag + 1]
			self.openDialog=nil
			local tabTb = {} -- 切换页签
			local tabType = nil
			local acTitle -- 活动标题
			local tabInitIndex = nil -- 初始标签
			if(acVo)then
			    activityVoApi:updateUserDefaultAfterRead(acVo.type)
			end
			self:updateNewNum() -- 更新
			self.lbTab={}
			self.nhtimeTb={}
			local recordPoint = self.tv:getRecordPoint()
			self.tv:reloadData()
			self.tv:recoverToRecordPoint(recordPoint)

			if acVo.type == "firstRecharge" then
				self.openDialog = acFirstRechargeDialog:new()
				self.openDialog:initVo(acVo)
				self.openDialog:init(self.layerNum+1)
				acTitle = getlocal("activity")
				do return end
			elseif acVo.type == "discount" then
				if acVo.version ~=nil and (acVo.version==2 or acVo.version==3) then
					acTitle = getlocal("activity_BlackFriday_title")
				elseif acVo.version ~=nil and acVo.version==4 then
					acTitle = getlocal("activity_discount_title3")
				elseif acVo.version ~=nil and (acVo.version==5 or acVo.version==6) then
					acTitle = getlocal("activity_discount_newYearTitle")
				elseif acVo.version ~=nil and acVo.version ==10 then
					acTitle = getlocal("activity_discount_title10")
				else
					acTitle = getlocal("activity_discount_title")
				end
				self.openDialog =  acDiscountDialog:new()
				self.openDialog:initVo(acVo)

			elseif acVo.type == "moscowGambling" then
				self.openDialog =  lotteryDialog:new()
				acTitle = getlocal("activity")
			elseif acVo.type =="moscowGamblingGai" then
				if acVo.version ==nil or acVo.version ==1 then
					acTitle =getlocal("activity_moscowGambling_title")
				elseif acVo.version ==2 then
					acTitle = getlocal("activity_monsterComeback_title")
				elseif acVo.version ==3 then
					acTitle = getlocal("activity_kuangnuzhishi_title")
				end
				self.openDialog = moscowGamblingGaiDialog:new()

			elseif acVo.type == "fbReward" then
				tabTb = {getlocal("activity_des_title"), getlocal("mainRank")}
				self.openDialog = acFbRewardDialog:new(self.layerNum + 1)
				local dialog=self.openDialog:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tabTb,nil,nil,getlocal("activity_fbReward_title"),true,self.layerNum + 1)
				self.openDialog:tabClick(0)
				sceneGame:addChild(dialog,self.layerNum + 1)
				do return end
			elseif acVo.type == "dayRecharge" then
				if acVo.version and acVo.version==3 then
					acTitle = getlocal("activity_dayRecharge_title_3")
				else
					acTitle = getlocal("activity_dayRecharge_title")
				end
				self.openDialog = acDayRechargeDialog:new(self.layerNum + 1)
				local dayReDialog = self.openDialog:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,nil,nil,acTitle,true,self.layerNum + 1)
				sceneGame:addChild(dayReDialog,self.layerNum + 1)
				do return end
			elseif acVo.type == "dayRechargeForEquip" then
				self.openDialog = acDayRechargeForEquipDialog:new(self.layerNum + 1)
				local dayReDialog = self.openDialog:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,nil,nil,getlocal("activity_dayRechargeForEquip_title"),true,self.layerNum + 1)
				sceneGame:addChild(dayReDialog,self.layerNum + 1)
				do return end
			elseif acVo.type == "fightRank" then
				tabTb = {getlocal("activity_des_title"), getlocal("mainRank")}
				self.openDialog = acFightRankDialog:new(self.layerNum + 1)
				local fightRDialog = self.openDialog:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tabTb,nil,nil,getlocal("activity_fightRank_title"),true,self.layerNum + 1)
				self.openDialog:tabClick(0)
				sceneGame:addChild(fightRDialog,self.layerNum + 1)
				do return end
			elseif acVo.type == "baseLeveling" then
				self.openDialog = acBaseLevelingDialog:new(self.layerNum + 1)
				local levelDialog = self.openDialog:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,nil,nil,getlocal("activity_baseLeveling_title"),true,self.layerNum + 1)
				sceneGame:addChild(levelDialog,self.layerNum + 1)
				do return end
			elseif acVo.type == "wheelFortune" then
				--tabTb = {getlocal("activity_wheelFortune_subTitle_1"),getlocal("activity_wheelFortune_subTitle_2"),getlocal("activity_wheelFortune_subTitle_3")}
				tabTb = {getlocal("activity_wheelFortune_subTitle_1"),getlocal("activity_wheelFortune_subTitle_2")}
				local td=acRouletteDialog:new(self.layerNum + 1)
				self.openDialog = td
				local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tabTb,nil,nil,getlocal("activity_wheelFortune_title"),true,self.layerNum + 1)
				-- td:tabClick(0)
				sceneGame:addChild(dialog,self.layerNum + 1)
				do return end
			elseif acVo.type == "allianceLevel" then
				tabTb = {getlocal("activity_des_title"), getlocal("mainRank")}
				self.openDialog = acAllianceLevelDialog:new(self.layerNum + 1)
				local allianceLevelDialog = self.openDialog:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tabTb,nil,nil,getlocal("activity_allianceLevel_title"),true,self.layerNum + 1)
				self.openDialog:tabClick(0)
				sceneGame:addChild(allianceLevelDialog,self.layerNum + 1)
				do return end
			elseif acVo.type == "allianceFight" then
				tabTb = {getlocal("activity_des_title"), getlocal("mainRank")}
				self.openDialog = acAllianceFightDialog:new(self.layerNum + 1)
				local allianceFightDialog = self.openDialog:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tabTb,nil,nil,getlocal("activity_allianceFight_title"),true,self.layerNum + 1)
				self.openDialog:tabClick(0)
				sceneGame:addChild(allianceFightDialog,self.layerNum + 1)
				do return end
			elseif acVo.type == "personalHonor" then
				tabTb = {getlocal("activity_des_title"), getlocal("mainRank")}
				self.openDialog = acPersonalHonorDialog:new(self.layerNum + 1)
				local personalHonorDialog = self.openDialog:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tabTb,nil,nil,getlocal("activity_personalHonor_title"),true,self.layerNum + 1)
				self.openDialog:tabClick(0)
				sceneGame:addChild(personalHonorDialog,self.layerNum + 1)
				do return end
			elseif acVo.type == "personalCheckPoint" then
				tabTb = {getlocal("activity_des_title"), getlocal("mainRank")}
				self.openDialog = acPersonalCheckPointDialog:new(self.layerNum + 1)
				local personalCheckPointDialog = self.openDialog:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tabTb,nil,nil,getlocal("activity_personalCheckPoint_title"),true,self.layerNum + 1)
				self.openDialog:tabClick(0)
				sceneGame:addChild(personalCheckPointDialog,self.layerNum + 1)
				do return end
			elseif acVo.type == "totalRecharge" then
				self.openDialog = acTotalRechargeDialog:new(self.layerNum + 1)
				local totalReDialog = self.openDialog:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,nil,nil,getlocal("activity_totalRecharge_title"),true,self.layerNum + 1)
				sceneGame:addChild(totalReDialog,self.layerNum + 1)
				do return end
			elseif acVo.type == "totalRecharge2" then
				self.openDialog = acTotalRecharge2Dialog:new(self.layerNum + 1)
			elseif acVo.type == "crystalHarvest" then
				local vrd=acCrystalYieldDialog:new()
				local vd = vrd:init(self.layerNum + 1)
				do return end
			elseif acVo.type == "equipSearch" then
				acEquipSearchVoApi:setFlag(2,-1)
				tabTb = {getlocal("activity_equipSearch_subTitle_1"), getlocal("mainRank")}
				self.openDialog = acEquipSearchDialog:new(self.layerNum + 1)
				local equipSearchDialog = self.openDialog:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tabTb,nil,nil,getlocal("activity_equipSearch_title"),true,self.layerNum + 1)
				self.openDialog:tabClick(0)
				sceneGame:addChild(equipSearchDialog,self.layerNum + 1)
				do return end
			elseif acVo.type == "rechargeRebate" then
				tabTb = {}
				self.openDialog = acRechargeRebateDialog:new(self.layerNum + 1)
				local dialog=self.openDialog:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tabTb,nil,nil,getlocal("activity_rechargeRebate_title"),true,self.layerNum + 1)
				sceneGame:addChild(dialog,self.layerNum + 1)
				do return end
            elseif acVo.type == "customRechargeRebate" then
				self.openDialog = acCustomRechargeRebateDialog:new(self.layerNum + 1)
			elseif acVo.type == "monsterComeback" then
				self.openDialog = acMonsterComebackDialog:new(self.layerNum + 1)
				local monsterComebackDialog = self.openDialog:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,nil,nil,getlocal("activity_monsterComeback_title"),true,self.layerNum + 1)
				sceneGame:addChild(monsterComebackDialog,self.layerNum + 1)
				do return end
			elseif acVo.type=="growingPlan" then
				self.openDialog = acGrowingPlanDialog:new()
				local vd = self.openDialog:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,getlocal("activity_growingPlan_title"),true,self.layerNum + 1);
				sceneGame:addChild(vd,self.layerNum + 1)
				do return end
			elseif acVo.type=="harvestDay" then
				self.openDialog = acHarvestDayDialog:new()
				local vd = self.openDialog:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,getlocal("activity_harvestDay_title"),true,self.layerNum + 1);
				sceneGame:addChild(vd,self.layerNum + 1)
				do return end
			elseif acVo.type=="oldUserReturn" then
				self.openDialog = acReturnDialog:new()
				local vd = self.openDialog:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{getlocal("activity_oldUserReturn_tab1"),getlocal("activity_oldUserReturn_stay"),""},nil,nil,getlocal("activity_oldUserReturn_title"),true,self.layerNum + 1);
				sceneGame:addChild(vd,self.layerNum + 1)
				do return end
			elseif acVo.type=="accessoryEvolution" then
				self.openDialog = acAccessoryUpgradeDialog:new(self,self.layerNum)
				local vd = self.openDialog:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,getlocal("activity_accessoryEvolution_title"),true,self.layerNum + 1);
				sceneGame:addChild(vd,self.layerNum + 1)
				do return end
			elseif acVo.type=="accessoryFight" then
				self.openDialog = acAccessoryFightDialog:new(self,self.layerNum)
				local vd = self.openDialog:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,getlocal("activity_accessoryFight_title"),true,self.layerNum + 1);
				sceneGame:addChild(vd,self.layerNum + 1)
				do return end
			elseif acVo.type=="jsss" then
				self.openDialog = acJsysDialog:new()
				local vd = self.openDialog:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{getlocal("activity_wheelFortune_subTitle_1"),getlocal("mainRank")},nil,nil,getlocal("activity_jsss_title"),true,self.layerNum + 1);
				sceneGame:addChild(vd,self.layerNum + 1)
				do return end
			elseif acVo.type=="allianceDonate" then
				self.openDialog = acAllianceDonateDialog:new()
				local vd = self.openDialog:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{getlocal("alliance_info_Introduction"),getlocal("mainRank")},nil,nil,getlocal("activity_allianceDonate_title"),true,self.layerNum + 1);
				sceneGame:addChild(vd,self.layerNum + 1)
				do return end
			elseif acVo.type == "equipSearchII" then
				acEquipSearchIIVoApi:setFlag(2,-1)
				tabTb = {getlocal("activity_equipSearch_subTitle_1"), getlocal("mainRank")}
				if acVo.version and (acVo.version ==4 or acVo.version ==2 or acVo.version==5) then
					acTitle = getlocal("activity_equipSearchIII_title")
				elseif acVo.version and ( acVo.version ==3 or acVo.version ==1 or acVo.version >= 6) then
					acTitle = getlocal("activity_"..acVo.type.."_title")
				end
				if acVo.version ==3 then
					self.openDialog = acTreasureOfKafukaDialog:new(self.layerNum+1)
				elseif acVo.version ==4 then
					self.openDialog = acKafukabaozangDialog:new(self.layerNum + 1)
				else
					self.openDialog = acEquipSearchIIDialog:new(self.layerNum+1)
				end
				local equipSearchDialog = self.openDialog:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tabTb,nil,nil,acTitle,true,self.layerNum + 1)
				self.openDialog:tabClick(0)
				sceneGame:addChild(equipSearchDialog,self.layerNum + 1)
				do return end
			elseif acVo.type=="rechargeDouble" then
				self.openDialog = acRechargeDoubleDialog:new()
				local vd = self.openDialog:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,getlocal("activity_rechargeDouble_title"),true,self.layerNum + 1);
				sceneGame:addChild(vd,self.layerNum + 1)
				do return end
			elseif acVo.type=="vipRight" then
				self.openDialog = acVipRightDialog:new()
				local vd = self.openDialog:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,getlocal("activity_vipRight_title"),true,self.layerNum + 1);
				sceneGame:addChild(vd,self.layerNum + 1)
				do return end
			elseif acVo.type=="heartOfIron" then
				self.openDialog = acHeartOfIronDialog:new()
				local vd = self.openDialog:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,getlocal("activity_heartOfIron_title"),true,self.layerNum + 1);
				sceneGame:addChild(vd,self.layerNum + 1)
				do return end    
			elseif acVo.type=="userFund" then
				self.openDialog = acUserFundDialog:new(self.layerNum + 1)
				tabTb = {getlocal("activity_userFund_subTitle_1"), getlocal("activity_userFund_subTitle_2")}
				local vd = self.openDialog:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tabTb,nil,nil,getlocal("activity_userFund_title"),true,self.layerNum + 1);
				sceneGame:addChild(vd,self.layerNum + 1)
				do return end
			elseif acVo.type=="tendayslogin" then
				self.openDialog = acTenDaysLoginDialog:new(self.layerNum + 1)
				tabTb = {}
				local vd = self.openDialog:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tabTb,nil,nil,getlocal("activity_tendayslogin_title"),true,self.layerNum + 1);
				sceneGame:addChild(vd,self.layerNum + 1)
				do return end
			elseif acVo.type=="vipAction" then
				self.openDialog = acVipActionDialog:new(self.layerNum + 1)
				tabTb = {}
				local vd = self.openDialog:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tabTb,nil,nil,getlocal("activity_vipAction_title"),true,self.layerNum + 1);
				sceneGame:addChild(vd,self.layerNum + 1)
				do return end
			elseif acVo.type=="investPlan" then
				self.openDialog = acInvestPlanDialog:new(self.layerNum + 1)
				tabTb = {}
				local vd = self.openDialog:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tabTb,nil,nil,getlocal("activity_investPlan_title"),true,self.layerNum + 1);
				sceneGame:addChild(vd,self.layerNum + 1)
				do return end      
			elseif acVo.type == "hardGetRich" then
				local dd = acHardGetRichDialog:new(self,self.layerNum)
				local tbArr={getlocal("activity_getRich_title1"),getlocal("activity_getRich_title2")}
				local vd = dd:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("activity_hardGetRich_title"),true,self.layerNum+1);
				sceneGame:addChild(vd,self.layerNum+1)
				do return end
			elseif acVo.type == "wheelFortune4" then
				tabTb = {getlocal("activity_wheelFortune4_subTitle_1"),getlocal("activity_wheelFortune4_subTitle_2")}
				self.openDialog=acRoulette4Dialog:new(self.layerNum + 1)
			elseif acVo.type == "wheelFortune2" then
				self.openDialog = acRoulette2Dialog:new(self,self.layerNum)
				tabTb={getlocal("activity_wheelFortune_subTitle_1"),getlocal("activity_wheelFortune_subTitle_2")}
			elseif acVo.type == "wheelFortune3" then
				self.openDialog = acRoulette3Dialog:new(self,self.layerNum)
				tabTb={getlocal("activity_wheelFortune_subTitle_1"),getlocal("activity_wheelFortune_subTitle_2")}
			elseif acVo.type == "armsRace" then
				self.openDialog = acArmsRaceDialog:new(self.layerNum + 1)
			elseif acVo.type == "stormrocket" then
				self.openDialog = acStormRocketDialog:new()
			elseif acVo.type =="zzrs" then
				self.openDialog = acThrivingDialog:new()
			elseif acVo.type == "openGift" then
				local function showOpenGift()
					self.openDialog = acOpenGiftDialog:new(self.layerNum + 1)
					local openGiftDialog = self.openDialog:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,nil,nil,getlocal("activity_openGift_title"),true,self.layerNum + 1)
					sceneGame:addChild(openGiftDialog,self.layerNum + 1)
				end
				if acVo.discountData == nil or SizeOfTable(acVo.discountData) < 2 then
					acOpenGiftVoApi:updateDiscountData(showOpenGift)
				else
					showOpenGift()
				end
				do return end
			elseif acVo.type == "grabRed" then
				if acVo.version ==1 or acVo.version ==nil then
					acTitle=getlocal("activity_grabRed_title")
				elseif acVo.version ==2 then
					acTitle=getlocal("activity_grabRed_titleB")
				elseif acVo.version ==3 then
					acTitle=getlocal("activity_grabRed_titleC")
				end
				self.openDialog = acGrabRedDialog:new()
			elseif acVo.type == "slotMachine" then
				self.openDialog = acSlotMachineDialog:new()
			elseif acVo.type == "slotMachine2" then
				self.openDialog = acSlotMachine2Dialog:new()
				acTitle = getlocal("activity_slotMachine_title")
            elseif acVo.type == "slotMachineCommon" then
				self.openDialog = acSlotMachineCommonDialog:new()
				acTitle = getlocal("activity_slotMachine_title")
			elseif acVo.type == "shareHappiness" then
				local function showShareHappiness()
					tabTb={getlocal("activityDescription"),getlocal("activity_shareHappiness_sub2")}
					self.openDialog = acShareHappinessDialog:new(self,self.layerNum)
					local openGiftDialog = self.openDialog:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tabTb,nil,nil,getlocal("activity_shareHappiness_title"),true,self.layerNum + 1)
					self.openDialog:tabClick(0)
					sceneGame:addChild(openGiftDialog,self.layerNum + 1)
				end
				acShareHappinessVoApi:getGiftListFromServer(showShareHappiness)
				do return end
			elseif acVo.type == "holdGround" then
				acIconUrl = "Icon_BG.png"
				local function timeIconClick( ... )
				end
				local addIconStr=""
				if acVo.version == 1 or acVo.version ==nil or acVo.version ==2 then
					addIconStr="7days.png"
				elseif acVo.version == 3 then
					addIconStr="360LOGO.png"
				elseif acVo.version ==4 then
					addIconStr="yuandanIcon.png"
					acTitle=getlocal("activity_holdGround_title_4")
				end
				addIcon = LuaCCSprite:createWithSpriteFrameName(addIconStr,timeIconClick)
				if acVo.version ==3 then
					addIcon:setScale(0.4)
				else
					addIcon:setScale(0.8)
				end
				self.openDialog = acHoldGroundDialog:new()
			elseif acVo.type == "holdGround1" then
				self.openDialog = acHoldGround1Dialog:new()  
			elseif acVo.type == "continueRecharge" then
				self.openDialog = acContinueRechargeDialog:new()
			elseif acVo.type == "lxcz" then
				self.openDialog = acContinueRechargeNewGuidDialog:new()
			elseif acVo.type == "miBao" then
				self.openDialog = acMiBaoDialog:new()
			elseif acVo.type == "fundsRecruit" then
				self.openDialog = acFundsRecruitDialog:new()
			elseif acVo.type == "armamentsUpdate1" then
				self.openDialog = acArmamentsUpdateDialog1:new()
			elseif acVo.type == "armamentsUpdate2" then
				self.openDialog = acArmamentsUpdateDialog2:new()
			elseif acVo.type == "rewardingBack" then
				self.openDialog = acRewardingBackDialog:new()
			elseif acVo.type == "leveling" then
				self.openDialog = acLevelingDialog:new()
			elseif acVo.type == "leveling2" then
				self.openDialog = acLeveling2Dialog:new()
				acTitle = getlocal("activity_leveling_title")
            elseif acVo.type == "autumnCarnival" then
				if acAutumnCarnivalVoApi:isAutumn() == false then
					acTitle = getlocal("activity_supplyIntercept_title")
				end
				self.openDialog = acAutumnCarnivalDialog:new()
			elseif acVo.type == "calls" then
				self.openDialog = acCallsDialog:new()
			elseif acVo.type == "newTech" then
				tabTb={getlocal("activity_newTech_tab1"),getlocal("activity_newTech_tab2")}
				self.openDialog = acNewTechDialog:new()
				tabInitIndex = 0
			elseif acVo.type == "luckUp" then
				self.openDialog = acLuckUpDialog:new()
			elseif acVo.type == "republicHui" then
				self.openDialog = acRepublicHuiDialog:new()
			elseif acVo.type == "nationalCampaign" then
				self.openDialog = acNationalCampaignDialog:new()
			elseif acVo.type == "ghostWars" then
				self.openDialog = acGhostWarsDialog:new()
			elseif acVo.type == "doorGhost" then
				self.openDialog = acDoorGhostDialog:new(self.layerNum)
				tabTb={getlocal("activity_doorGhost_openDoorTitle"),getlocal("activity_doorGhost_ghostRewardTitle")}
			elseif acVo.type == "refitPlanT99" then
				tabTb = {getlocal("activity_wheelFortune_subTitle_1"), getlocal("sample_build_name_14")}
				self.openDialog = acRefitPlanDialog:new()
			elseif acVo.type == "preparingPeak" then
				self.openDialog = acPreparingPeakDialog:new()
			elseif acVo.type == "singles" then
				tabTb = {getlocal("activity_singles_title"), getlocal("activity_singles_shoptitle")}
				self.openDialog = acSinglesDialog:new()
			elseif acVo.type == "cuikulaxiu" then
				tabTb = {getlocal("activity_getRich_title2"), getlocal("mainRank")}
				self.openDialog = acCuikulaxiuDialog:new()
			elseif acVo.type == "jidongbudui" then
				tabTb = {getlocal("activity_wheelFortune_subTitle_1"), getlocal("code_gift")}
				self.openDialog = acJidongbuduiDialog:new()
			elseif acVo.type == "kuangnuzhishi" then
				tabTb = {getlocal("activity_wheelFortune_subTitle_1"), getlocal("mainRank")}
				self.openDialog = acKuangnuzhishiDialog:new()
			elseif acVo.type == "baifudali" then
				if acVo.version == 3 then
					acTitle = getlocal("activity_baifudali_titleTW")
				else
					acTitle = getlocal("activity_baifudali_title")
				end
				self.openDialog =acBaifudaliDialog:new()
			elseif acVo.type == "feixutansuo" then
				if acVo.version >9 then
					if 	acVo.version<14 then
						if acVo.version  ==10 then
							acVo.version = 1
						elseif acVo.version ==11 then
							acVo.version = 2
						elseif acVo.version ==12 then
							acVo.version = 3
						elseif acVo.version ==13 then
							acVo.version = 4
						end
					elseif acVo.version >= 14 then
						if acVo.version ==14 then
							acVo.version = 5
						elseif acVo.version ==15 then
							acVo.version = 6
						elseif acVo.version ==16 then
							acVo.version = 7
						elseif acVo.version ==17 then
							acVo.version = 8
						elseif acVo.version >=18 then
							acVo.version = 9				
						end
					end
				end
				if acVo.version ==nil  or acVo.version <5 then
					if acVo.version ==nil or acVo.version ==1 then
						acTitle = getlocal("activity_feixutansuo_title1")
					elseif acVo.version ==2 then
						acTitle = getlocal("activity_feixutansuo_title2")
					elseif acVo.version ==3 then
						acTitle = getlocal("activity_feixutansuo_title3")
					elseif acVo.version ==4 then
						acTitle = getlocal("activity_feixutansuo_title4")
					end
				elseif acVo.version >= 5 then
					if acVo.version ==5 then
						acTitle = getlocal("activity_feixutansuo_title5")
					elseif acVo.version ==6 then
						acTitle = getlocal("activity_feixutansuo_title6")
					elseif acVo.version ==7 then
						acTitle = getlocal("activity_feixutansuo_title7")
					elseif acVo.version ==8 then
						acTitle = getlocal("activity_feixutansuo_title8")
					elseif acVo.version ==9 then
						acTitle = getlocal("activity_feixutansuo_title9")
					end
				end
				if base.mustmodel==1 and acFeixutansuoVoApi:getMustMode() then
					acTitle=getlocal("acFeixutansuoNew_title")
					tabTb = {getlocal("limitedTask"), getlocal("sample_build_name_14")}
				else
					tabTb = {getlocal("activity_feixutansuo_tansuoTitle"), getlocal("sample_build_name_14")}
				end
				
				self.openDialog = acFeixutansuoDialog:new()
			elseif acVo.type == "zhenqinghuikui" then
				if acVo.version ==3 then
					acTitle = getlocal("activity_zhenqinghuikui_title3")
				elseif acVo.version ==4 or acVo.version==5 or acVo.version==6 or acVo.version==7 then
					acTitle = acRoulette5VoApi:getAcName()
				else
					acTitle = getlocal("activity_zhenqinghuikui_title")
				end
				self.openDialog =acRoulette5Dialog:new()
			elseif acVo.type == "shengdanbaozang" then
				if acVo.version ==1 or acVo.version ==2 or acVo.version ==nil then
					acTitle = getlocal("activity_shengdanbaozang_title")
					tabTb = {getlocal("activity_shengdanbaozang_lotteryTitle"), getlocal("activity_shengdanbaozang_shopTitle")}
				elseif acVo.version ==3 or acVo.version ==4 then
					acTitle = getlocal("activity_mysteriousArms_title")
					tabTb = {getlocal("activity_mysteriousArms_business"), getlocal("activity_mysteriousArms_shop")}
				end
				self.openDialog = acShengdanbaozangDialog:new()
			elseif acVo.type == "shengdankuanghuan" then
				if acVo.version ~=3 then
					tabTb = {getlocal("activity_shengdankuanghuan_RebatesTitle"), getlocal("activity_shengdankuanghuan_ChristmasTree")}
				elseif acVo.version ==3 then
					acTitle = getlocal("activity_shengdankuanghuan_titleB")
					tabTb = {getlocal("activity_munitionsSales"), getlocal("activity_asenal")}
				end
				self.openDialog = acShengdankuanghuanDialog:new()
			elseif acVo.type == "yuandanxianli" then
				tabTb ={getlocal("activity_wheelFortune_subTitle_1"),getlocal("activity_yuandanxianli_subTitle2"),getlocal("activity_yuandanxianli_subTitle3")}
				self.openDialog = acYuandanxianliDialog:new()
			elseif acVo.type == "onlineReward" then
				self.openDialog =acOnlineRewardDialog:new()
			elseif acVo.type == "online2018" then
				self.openDialog =acOnlineRewardXVIIIDialog:new()
			elseif acVo.type == "tankjianianhua" then
				self.openDialog = acTankjianianhuaDialog:new()
			elseif acVo.type == "xuyuanlu" then
				tabTb ={getlocal("activity_xuyuanlu_goldTitle"),getlocal("activity_xuyuanlu_propTitle")}
				self.openDialog = acXuyuanluDialog:new()
			elseif acVo.type == "shuijinghuikui" then
				self.openDialog = acShuijinghuikuiDialog:new()
			elseif acVo.type == "xinchunhongbao" then
				self.openDialog = acXinchunhongbaoDialog:new()
			elseif acVo.type == "huoxianmingjiang" then
				acTitle = getlocal("activity_huoxianmingjiang_title1")
				self.openDialog = acHuoxianmingjiangDialog:new()
			elseif acVo.type == "xinfulaba" then
				acTitle = getlocal("activity_xinfulaba_title")
				if playerVoApi:getPlayerLevel() >=5 then
					self.openDialog = acLuckyCatDialog:new()
				end
			elseif acVo.type == "junshijiangtan" then	
				if acVo.version ==1 or acVo.version ==nil then
					acTitle = getlocal("activity_junshijiangtan_title")
				else
					acTitle = getlocal("activity_junshijiangtan_titleB")
				end						
				-- acTitle = getlocal("activity_junshijiangtan_title")
				tabTb ={getlocal("activity_junshijiangtan_tab1_title"),getlocal("mainRank")}
				self.openDialog = acJunshijiangtanDialog:new()
			elseif acVo.type == "huoxianmingjianggai" then
				acTitle = getlocal("activity_huoxianmingjiang_title1")
				tabTb ={getlocal("recruit"),getlocal("mainRank")}
				self.openDialog = acMingjiangDialog:new()
			elseif acVo.type == "diancitanke" then
				acTitle = getlocal("activity_diancitanke_title1")
				tabTb ={getlocal("activity_diancitanke_tab1_title"),getlocal("smelt")}
				self.openDialog = acDiancitankeDialog:new()
			elseif acVo.type == "sendaccessory" then
				acTitle = getlocal("activity_peijianhuzeng_title")
				tabTb ={}
				self.openDialog = acPeijianhuzengDialog:new()
			elseif acVo.type == "tianjiangxiongshi" then
				acTitle = getlocal("activity_tianjiangxiongshi_title")
				tabTb ={}
				self.openDialog = acTianjiangxiongshiDialog:new()
			elseif acVo.type == "quanmintanke" then
				acTitle = getlocal("activity_quanmintanke_title")
				tabTb ={}
				if base.mustmodel==1 and acQuanmintankeVoApi:getMustMode() then
					self.openDialog = acQuanmintankeNewDialog:new()
				else
					self.openDialog = acQuanmintankeDialog:new()
				end
				
			elseif acVo.type == "taibumperweek" then
				acTitle = acTitaniumOfharvestVoApi:getTitleName()
				if base.alien==1 then
					tabTb ={getlocal("activity_rechargeRebate_title"),getlocal("activity_TitaniumOfharvest_tab2"),getlocal("activity_TitaniumOfharvest_tab3")}
				else
					tabTb ={getlocal("activity_rechargeRebate_title"),getlocal("activity_TitaniumOfharvest_tab2")}
				end
				self.openDialog = acTitaniumOfharvestDialog:new()
			elseif acVo.type == "junzipaisong" then
				self.openDialog = acJunzipaisongDialog:new()
			elseif acVo.type == "chongzhiyouli" then
				acTitle=acChongZhiYouLiVoApi:getAcName()
				self.openDialog = acChongZhiYouLiDialog:new()
			elseif acVo.type =="songjiangling" then
				acTitle = getlocal("activity_SendGeneral_title")
				self.openDialog = acSendGeneralDialog:new()
			elseif acVo.type =="xingyunzhuanpan" then
				acTitle =getlocal("activity_mayDay_title")
				tabTb ={getlocal("acMayDay_tab1_title"),getlocal("acMayDay_tab2_title")}
				self.openDialog =acMayDayDialog:new()
			elseif acVo.type =="yunxingjianglin" then
				acTitle =getlocal("activity_meteoriteLanding_title")
				tabTb ={getlocal("activity_meteoriteLanding_Tab1"),getlocal("activity_meteoriteLanding_Tab2"),getlocal("activity_meteoriteLanding_Tab3")}
				self.openDialog =acMeteoriteLandingDialog:new()				
			elseif acVo.type =="hongchangyuebing" then
				acTitle =getlocal("activity_hongchangyuebing_title")
				self.openDialog = acHongchangyuebingDialog:new()
			elseif acVo.type =="huiluzaizao" then
				acTitle =getlocal("activity_recycling_title")
				tabTb ={getlocal("activity_wheelFortune_subTitle_1"),getlocal("activity_recycling_tip2"),getlocal("activity_recycling_tip3")}
				self.openDialog =acRecyclingDialog:new()
			elseif acVo.type =="banzhangshilian" then
				tabTb ={getlocal("activity_banzhangshilian_tab1_title"),getlocal("activity_banzhangshilian_tab2_title")}
				self.openDialog =acBanzhangshilianDialog:new()
			elseif acVo.type == "kafkagift" then
				local version =  acKafkaGiftVoApi:getVersion()
				if version==nil or version==1 or version==2 then
					acTitle =getlocal("activity_kafkagift_title")
				else
					acTitle =getlocal("activity_kafkagift_title" .. version)
				end
				self.openDialog = acKafkaGiftDialog:new()
			elseif acVo.type =="twohero" then 
				acTitle =getlocal("activity_heroGift_title")
				tabTb ={getlocal("recruit"),getlocal("mainRank")}
				self.openDialog = acHeroGiftDialog:new()
			elseif acVo.type =="alienbumperweek" then
				tabTb =nil
				self.openDialog =acAlienbumperweekDialog:new()	
			elseif acVo.type =="ydjl2" then
				acTitle =getlocal("activity_acYueduTwoHero_title")
				self.openDialog =acYueduHeroTwoDialog:new()
			elseif acVo.type =="yuedujiangling" then
				acTitle =getlocal("activity_acYueduHero_title")
				self.openDialog =acYueduHeroDialog:new()
			elseif acVo.type =="haoshichengshuang" then
				acTitle =getlocal("activity_haoshichengshuang_title")
				self.openDialog =acHaoshichengshuangDialog:new()	
			elseif acVo.type =="gangtieronglu" then
				acTitle =getlocal("activity_gangtieronglu_title")
				tabTb ={getlocal("activity_gangtieronglu_tab1"),getlocal("task")}
				self.openDialog =acGangtierongluDialog:new()	
			elseif acVo.type =="xingyunpindian" then
				acTitle =getlocal("activity_xingyunpindian_title")
				self.openDialog =acXingyunpindianDialog:new()
			elseif acVo.type =="xiaofeisongli" then
				acTitle =getlocal("activity_xiaofeisongli_title_1")
				self.openDialog =acXiaofeisongliDialog:new()
			elseif acVo.type =="ybsc" then
				acTitle =getlocal("activity_yuebingshencha_title")
				local str1=getlocal("activity_yuebingshencha_tab1")
				if acYuebingshenchaVoApi:getVersion()==2 then
					acTitle =getlocal("activity_yuebingshencha_title_2")
					str1=getlocal("activity_yuebingshencha_tab1_2")
				end
				tabTb ={str1,getlocal("activity_yuebingshencha_tab2")}
				self.openDialog = acYuebingshenchaDialog:new()
			elseif acVo.type =="chongzhisongli" then -- 累计充值送好礼
		        acTitle =getlocal("activity_chongzhisongli_title_1")
				self.openDialog =acChongzhisongliDialog:new()
		    elseif acVo.type =="danrichongzhi" then -- 单日充值
		        acTitle =getlocal("activity_danrichongzhi_title_1")
				self.openDialog =acDanrichongzhiDialog:new()
			elseif acVo.type =="mrcz" then -- 每日充值(新手绑定版)
		        acTitle =getlocal("activity_dailyRechargeByNewGuider_title")
				self.openDialog =acDailyRechargeByNewGuiderDialog:new()
		    elseif acVo.type =="danrixiaofei" then -- 单日消费
		        acTitle =getlocal("activity_danrixiaofei_title_1")
				self.openDialog =acDanrixiaofeiDialog:new()	
			elseif acVo.type =="swchallengeactive" then
				acTitle =getlocal("activity_swchallengeactive_title")
				self.openDialog =acSwchallengeactiveDialog:new()
			elseif acVo.type =="jiejingkaicai" then
				acTitle =getlocal("activity_jiejingkaicai_title")
				self.openDialog =acJiejingkaicaiDialog:new()		
			elseif acVo.type =="jffp" then
				acTitle =getlocal("activity_jffp_title")
				self.openDialog =acJffpDialog:new()		
			elseif acVo.type == "firstRechargenew" then
				acTitle = getlocal("activity_firstRechargenew_title")
				self.openDialog = acFirstRechargenewDialog:new()
				self.openDialog:initVo(acVo)
			elseif acVo.type =="zhanshuyantao" then
				acTitle = getlocal("activity_zhanshuyantao_title")
				self.openDialog = acTacticalDiscussDialog:new(self.layerNum + 1)
			elseif acVo.type == "fightRanknew" then
				tabTb = {getlocal("activity_des_title"), getlocal("mainRank")}
				self.openDialog = acFightRanknewDialog:new(self.layerNum + 1)
				local fightRanknewDialog = self.openDialog:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tabTb,nil,nil,getlocal("activity_fightRanknew_title"),true,self.layerNum + 1)
				self.openDialog:tabClick(0)
				sceneGame:addChild(fightRanknewDialog,self.layerNum + 1)
				do return end
			elseif acVo.type == "yongwangzhiqian" then
				self.openDialog = acMoveForwardDialog:new()
				local dialogBg = self.openDialog:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,getlocal("activity_yongwangzhiqian_title"),true,self.layerNum + 1)
				sceneGame:addChild(dialogBg,self.layerNum + 1)
				do return end
			elseif acVo.type == "ywzq" then
				self.openDialog = acYwzqDialog:new()
				local dialogBg = self.openDialog:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,getlocal("activity_ywzq_title"),true,self.layerNum + 1)
				sceneGame:addChild(dialogBg,self.layerNum + 1)
				do return end
			elseif acVo.type == "halloween" then
				tabTb = {getlocal("activity_halloween_tab_1"), getlocal("activity_halloween_tab_2")}
				self.openDialog = acSweetTroubleDialog:new(self.layerNum + 1)
				local sweetTroubleDialog = self.openDialog:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tabTb,nil,nil,getlocal("activity_halloween_title"),true,self.layerNum + 1)
				self.openDialog:tabClick(0)
				sceneGame:addChild(sweetTroubleDialog,self.layerNum + 1)
				do return end
			elseif acVo.type=="twolduserreturn" then
				self.openDialog = acOldReturnDialog:new()
				local vd = self.openDialog:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{getlocal("activity_oldUserReturn_stay"),getlocal("activity_twolduserreturn_tab2"),getlocal("activity_twolduserreturn_tab3")},nil,nil,getlocal("activity_oldUserReturn_title"),true,self.layerNum + 1);
				sceneGame:addChild(vd,self.layerNum + 1)
				do return end
			elseif acVo.type =="rechargeCompetition" then
				self.openDialog = acRechargeGameDialog:new()
				tabTb = {getlocal("activity_des_title"),getlocal("mainRank")}
				local rechargeGameDialog = self.openDialog:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tabTb,nil,nil,getlocal("activity_rechargeCompetition_title"),true,self.layerNum + 1)
				sceneGame:addChild(rechargeGameDialog,self.layerNum + 1)
				do return end
			elseif acVo.type == "challengeranknew" then
				tabTb = {getlocal("activity_des_title"), getlocal("mainRank")}
				self.openDialog = acChallengeranknewDialog:new(self.layerNum + 1)
				local challengeranknewDialog = self.openDialog:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tabTb,nil,nil,getlocal("activity_challengeranknew_title"),true,self.layerNum + 1)
				self.openDialog:tabClick(0)
				sceneGame:addChild(challengeranknewDialog,self.layerNum + 1)
				do return end
			elseif acVo.type == "double11new" then
				acTitle =getlocal("activity_double11New_title")
				local tabTb = {getlocal("activity_double11New_tab1"), getlocal("activity_double11New_tab2"),getlocal("activity_double11New_tab3")}
				self.openDialog = acDouble11NewDialog:new(self.layerNum + 1)
				local double11NewDialog = self.openDialog:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tabTb,nil,nil,acTitle,true,self.layerNum + 1)
				self.openDialog:tabClick(0)
				sceneGame:addChild(double11NewDialog,self.layerNum + 1)
				do return end
			elseif acVo.type == "double11" then
				local tabTb = {}
				if acVo.version ==nil or acVo.version ==1 then
					acTitle =getlocal("activity_double11_title")
					tabTb = {getlocal("activity_double11_tab1"), getlocal("activity_double11_tab2")}
				elseif acVo.version ==2 then
					acTitle =getlocal("activity_cnNewYear_title")
					tabTb = {getlocal("activity_cnNewYear_tab1"), getlocal("activity_cnNewYear_tab2")}
				elseif acVo.version >2 then
					acTitle = getlocal("activity_double11_title_ver_"..acVo.version)
					tabTb = {getlocal("activity_double11_tab1_ver_"..acVo.version), getlocal("activity_double11_tab2_ver_"..acVo.version)}
				end
				self.openDialog = acDouble11Dialog:new(self.layerNum + 1)
				local double11Dialog = self.openDialog:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tabTb,nil,nil,acTitle,true,self.layerNum + 1)
				self.openDialog:tabClick(0)
				sceneGame:addChild(double11Dialog,self.layerNum + 1)
				do return end
			elseif acVo.type =="new112018" then
				local tabTb = {}
				if acVo.version ==nil or acVo.version ==1 then
					acTitle =getlocal("activity_new112018_title")
					tabTb = {getlocal("activity_new112018_tab1"), getlocal("activity_new112018_tab2")}
				end
				if acTitle==nil or acTitle=="" then
					acTitle =getlocal("activity_new112018_title")
					tabTb = {getlocal("activity_new112018_tab1"), getlocal("activity_new112018_tab2")}
				end
				self.openDialog = acDoubleOneDialog:new(self.layerNum + 1)
				local doubleOneDialog = self.openDialog:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tabTb,nil,nil,acTitle,true,self.layerNum + 1)
				self.openDialog:tabClick(0)
				sceneGame:addChild(doubleOneDialog,self.layerNum + 1)
				do return end
			elseif acVo.type == "wanshengjiedazuozhan" then
				local version=acWanshengjiedazuozhanVoApi:getVersion()
				if version and version>1 then
					acTitle = getlocal("activity_wanshengjiedazuozhan_title_"..version)
				else
					acTitle = getlocal("activity_wanshengjiedazuozhan_title")
				end
				tabTb ={getlocal("activity_wheelFortune_subTitle_1"),getlocal("task")}
				self.openDialog = acWanshengjiedazuozhanDialog:new()
				tabInitIndex=0
			elseif acVo.type == "yijizaitan" then
				acTitle = getlocal("activity_yijizaitan_title")
				tabTb = {getlocal("activity_feixutansuo_tansuoTitle"), getlocal("sample_build_name_14")}
				self.openDialog = acYijizaitanDialog:new()
			elseif acVo.type == "ganenjiehuikui" then
				acTitle = getlocal("activity_ganenjiehuikui_title")
				tabTb ={getlocal("activity_ganenjiehuikui_tab2"),getlocal("activity_ganenjiehuikui_tab1")}
				self.openDialog = acThanksGivingDialog:new()
			elseif acVo.type == "christmasfight" then
				if(playerVoApi:getPlayerLevel()<20)then
					smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_newyearseve_lvllack",{20}),30)
				else
					if acChristmasFightVoApi:getAcShowType()==acChristmasFightVoApi.acShowType.TYPE_2 then
						acTitle = getlocal("activity_christmasfight_title_1")
					else
						acTitle = getlocal("activity_christmasfight_title")
					end
					tabTb ={getlocal("activity_christmasfight_tab1"),getlocal("activity_christmasfight_tab2"),getlocal("activity_christmasfight_tab3")}
					self.openDialog = acChristmasFightDialog:new()
				end
			elseif acVo.type == "mingjiangzailin" then
				acTitle = getlocal("activity_mingjiangzailin_title")
				self.openDialog = acMingjiangzailinDialog:new()
			elseif acVo.type == "tankbattle" then
				acTitle = getlocal("activity_tankbattle_title")
				self.openDialog = acTankBattleStartDialog:new()
			elseif acVo.type =="shengdanqianxi" then
				if(acChrisEveVoApi and ( acChrisEveVoApi:isNormalVersion() or acChrisEveVoApi:getVersion() == 5 ))then
					acTitle =getlocal("activity_chrisEve_title_1")
					tabTb ={getlocal("activity_chrisEve_tab1_1"),getlocal("market"),getlocal("rank")}
				else
					acTitle =getlocal("activity_chrisEve_title")
					tabTb ={getlocal("activity_chrisEve_tab1"),getlocal("activity_chrisEve_tab2"),getlocal("activity_chrisEve_tab3")}
				end
				self.openDialog =acChrisEveDialog:new(self.layerNum + 1)
			elseif acVo.type == "newyeargift" then
				acTitle = getlocal("activity_newyeargift_title")
				self.openDialog = acNewYearDialog:new()
			elseif acVo.type =="stormFortress" then
				acTitle = getlocal("activity_stormFortress_title")
				self.openDialog = acStormFortressDialog:new(self.layerNum + 1)
			elseif acVo.type =="yichujifa" then
				acTitle =getlocal("activity_yichujifa_title")
				tabTb ={getlocal("activity_yichujifa_tip1"),getlocal("activity_yichujifa_tip2"),getlocal("activity_yichujifa_tip3")}
				if playerVoApi:getPlayerLevel() >2 then
					self.openDialog =acImminentDialog:new(self.layerNum + 1)
				end
			elseif acVo.type =="anniversary" then
				acTitle =getlocal("activity_anniversary_title")
				if(playerVoApi:getPlayerLevel()<20)then
					smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_newyearseve_lvllack",{20}),30)
				else
					tabTb={}
					self.openDialog=acAnniversaryDialog:new()
				end
			elseif acVo.type =="smcj" then
				if(playerVoApi:getPlayerLevel()<60)then
					smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_newyearseve_lvllack",{60}),30)
					do return end
				end

				acTitle = getlocal("activity_smcj_title")
				tabTb = {getlocal("task"), getlocal("mainRank")}
				self.openDialog = acSmcjDialog:new()
			elseif acVo.type =="hljb" then

				acTitle = getlocal("activity_hljb_title")
				tabTb = {getlocal("activity_hljb_tabOneTitle"), getlocal("activity_hljb_tabTwoTitle")}
				self.openDialog = acHljbDialog:new()
			elseif acVo.type =="chunjiepansheng" then
				local version=acChunjiepanshengVoApi:getVersion()
				acTitle = getlocal("activity_chunjiepansheng_title"  .. "_ver" .. version)
				if version and version==3 then
					tabTb = {getlocal("activity_chunjiepansheng_tab1"), getlocal("activity_chunjiepansheng_tab2_ver" .. version)}
				else
					tabTb = {getlocal("activity_chunjiepansheng_tab1"), getlocal("activity_chunjiepansheng_tab2")}
				end
				self.openDialog = acChunjiepanshengDialog:new()
			elseif acVo.type == "newyeareva" then
				--判断玩家等级是否可以参加年兽活动
				local isEnable,level = acNewYearsEveVoApi:isCanJoinActivity()
				if isEnable == false then
					--弹出等级不足的提示
					smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_newyearseve_lvllack",{level}),30)
				else
					local _tab1Title=getlocal("activity_newyearseve_name")
					if acNewYearsEveVoApi:getAcShowType()==acNewYearsEveVoApi.acShowType.TYPE_2 then
						acTitle = getlocal("activity_newyearseve_title_1")
						_tab1Title=getlocal("activity_newyearseve_name_1")
					else
					acTitle = getlocal("activity_newyearseve_title")
					end
					tabTb ={_tab1Title,getlocal("BossBattle_damageRank"),getlocal("fleetCard")}
					self.openDialog = acNewYearsEveDialog:new()
				end
			elseif acVo.type=="dailyEquipPlan" then
				local isEnable,level = acDailyEquipPlanVoApi:isCanJoinActivity()
				if isEnable == false then
					--弹出等级不足的提示
					smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_newyearseve_lvllack",{level}),30)
				else
					acTitle=getlocal("activity_dailyequip_title")
					self.openDialog=acDailyEquipPlanDialog:new()
				end
			elseif acVo.type=="seikoStoneShop" then
				local isEnable,level = acSeikoStoneShopVoApi:isCanJoinActivity()
				if isEnable == false then
					--弹出等级不足的提示
					smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_newyearseve_lvllack",{level}),30)
				else
					acTitle=getlocal("activity_seikostone_shop_title")
					self.openDialog=acSeikoStoneShopDialog:new()
				end
			elseif acVo.type=="anniversaryBless" then
				acTitle=getlocal("activity_anniversaryBless_title")
				self.openDialog=acAnniversaryBlessDialog:new()
				tabTb={getlocal("activity_anniversaryBless_tab1"), getlocal("activity_anniversaryBless_title")}
			elseif acVo.type=="blessingWheel" then
				local anniversaryVo=activityVoApi:getActivityVo("anniversaryBless")
				if anniversaryVo==nil then
					--提示周年狂欢活动没有开启
					smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("anniversary_not_open"),30)	
				else
					acTitle=getlocal("activity_blessingwheel_title")
					self.openDialog=acBlessingWheelDialog:new()
				end
			elseif acVo.type=="monthlysign" then
				acTitle=getlocal("activity_monthlysign_title")
				self.openDialog=acMonthlySignDialog:new()
				tabTb={getlocal("activity_monthlysign_title"), getlocal("activity_monthlysign_pay")}
			elseif acVo.type == "customLottery1" then
				self.openDialog = acCustomLotteryOneDialog:new()
			-- elseif acVo.type =="buyreward" then
			-- 	acTitle =getlocal("activity_buyreward_title" .. acBuyrewardVoApi:getNameType())
			-- 	tabTb ={}
			-- 	self.openDialog=acBuyrewardDialog:new()
			elseif acVo.type=="rechargebag" then
				acTitle = getlocal("activity_rechargebag_title")
				tabTb ={getlocal("recharge"),getlocal("generosity_rank")}
				self.openDialog = acRechargeBagDialog:new()
			elseif acVo.type=="benfuqianxian" then
				acTitle=getlocal("activity_benfuqianxian_title")
				self.openDialog=acBenfuqianxianDialog:new()
				tabTb={getlocal("award"), getlocal("task")}
			elseif acVo.type=="aoyunjizhang" then
				acTitle=getlocal("activity_aoyunjizhang_title")
				self.openDialog=acOlympicCollectDialog:new()
			elseif acVo.type=="battleplane" then
				acTitle=getlocal("activity_battleplane_title")
				self.openDialog=acAntiAirDialog:new()
			elseif acVo.type=="mingjiangpeiyang" then
				acTitle=getlocal("activity_mingjiangpeiyang_title")
				self.openDialog=acMingjiangpeiyangDialog:new()
			elseif acVo.type=="midautumn" then
				acTitle=acMidAutumnVoApi:getVersion() == 3 and getlocal("activity_midautumn_v2_title") or getlocal("activity_midautumn_title")
				self.openDialog=acMidAutumnDialog:new()
				tabTb=acMidAutumnVoApi:getVersion() == 3 and {getlocal("activity_midautumn_v2_tabName2"),getlocal("activity_midautumn_v2_tabName1"),getlocal("activity_midautumn_tabName3")} or {getlocal("activity_midautumn_tabName2"),getlocal("activity_midautumn_tabName1"),getlocal("activity_midautumn_tabName3")}
			elseif acVo.type=="zhanyoujijie" then
				acTitle=getlocal("activity_zhanyoujijie_title")
				self.openDialog=acZhanyoujijieDialog:new()
				tabTb={getlocal("activity_zhanyoujijie_sub_title1"),getlocal("activity_zhanyoujijie_sub_title2")}
			elseif acVo.type=="threeyear" then
				acTitle=getlocal("activity_threeyear_title")
				self.openDialog=acThreeYearDialog:new()
				tabTb={getlocal("activity_threeyear_tab1"),getlocal("activity_threeyear_tab2"),getlocal("activity_threeyear_tab3")}
			elseif acVo.type=="mineExplore" then
				acTitle=getlocal("activity_mineExplore_title")
				self.openDialog=acMineExploreDialog:new()
				tabTb={getlocal("activity_mineExplore_title"),getlocal("activity_mineExplore_shop")}
			elseif acVo.type=="mineExploreG" then
				acTitle=getlocal("activity_mineExploreG_title")
				self.openDialog=acMineExploreGDialog:new()
				tabTb={getlocal("activity_mineExploreG_title"),getlocal("activity_mineExploreG_shop")}
			elseif acVo.type=="wdyo" then
				acTitle=getlocal("activity_loversDay_title")
				self.openDialog=acLoversDayDialog:new()
				tabTb={getlocal("activity_loversDay_tab1"),getlocal("activity_loversDay_tab2")}
			elseif acVo.type=="christmas2016" then
				acTitle=getlocal("activity_christmas2016_title")
				self.openDialog=acChristmasAttireDialog:new()
				tabTb={getlocal("activity_christmas2016_title"),getlocal("mainRank")}
			elseif acVo.type=="djrecall" then
				acTitle=getlocal("activity_generalRecall_title")
				self.openDialog=acGeneralRecallDialog:new()
				if acGeneralRecallVoApi:getPlayerType( ) == 2 then --需要判断是活跃玩家 还是被召回玩家
					tabTb={getlocal("activity_generalRecall_tab1"),getlocal("activity_generalRecall_tab2_1")}
				else
					tabTb={getlocal("activity_generalRecall_tab1"),getlocal("activity_generalRecall_tab2_2")}
				end
			elseif acVo.type=="cjyx" then
				acTitle=getlocal("activity_cjyx_title")
				self.openDialog=acCjyxDialog:new()
				tabTb={getlocal("activity_cjyx_title"),getlocal("mainRank")}
			elseif acVo.type=="yswj" then
				acTitle=getlocal("activity_yswj_title")
				self.openDialog=acYswjDialog:new()
				tabTb={getlocal("activity_meteoriteLanding_collect"),getlocal("activity_meteoriteLanding_Tab2"),getlocal("task")}
			elseif acVo.type=="ljcz" then
				acTitle=getlocal("activity_ljcz_title")
				self.openDialog=acLjczDialog:new()
			elseif acVo.type=="ljcz3" then
				acTitle=getlocal("activity_ljcz3_title")
				self.openDialog=acSuperLjczDialog:new()
			elseif acVo.type=="sdzs" then
				acTitle=getlocal("activity_sdzs_title")
				self.openDialog=acSdzsDialog:new()
			elseif acVo.type=="ramadan" then
				acTitle=getlocal("activity_ramadan_title")
				self.openDialog=acRamadanDialog:new()
			elseif acVo.type=="phlt" then
				acTitle=getlocal("activity_phlt_title")
				self.openDialog=acPhltDialog:new()
				tabTb={getlocal("activity_phlt_tab1"),getlocal("activity_loversDay_tab2")}
			elseif acVo.type=="kljz" then
				acTitle=getlocal("activity_kljz_title")
				self.openDialog=acKljzDialog:new()
				tabTb={getlocal("activity_kljz_tab1"),getlocal("activity_kljz_tab2")}
			elseif acVo.type=="hxgh" then
				acTitle=getlocal("activity_hxgh_title")
				local openLv=acHxghVoApi:getOpenLevel()
				if(playerVoApi:getPlayerLevel()<openLv)then
					smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_newyearseve_lvllack",{openLv}),30)
				else
					self.openDialog=acHxghDialog:new()
					tabTb={getlocal("activity_hxgh_plan"),getlocal("activity_loversDay_tab2")}
				end
			elseif acVo.type=="fuyunshuangshou" then
				acTitle = getlocal("activity_fyss_title")
				tabTb={getlocal("code_gift"),getlocal("activity_wheelFortune_subTitle_1")}
				self.openDialog = acFyssDialog:new()
			elseif acVo.type=="znkh" then
				if acZnkhVoApi and acZnkhVoApi:getVersion()==3 then
					acTitle = getlocal("activity_znkh_title_3")
				else
					acTitle = getlocal("activity_znkh2017_title")
				end
				tabTb={getlocal("activity_wheelFortune_subTitle_1"),getlocal("mainRank")}
				self.openDialog=acZnkhDialog:new(self.layerNum+1)
			elseif acVo.type=="lmqrj" then
				if acLmqrjVoApi and acLmqrjVoApi:getVersion()==2 then
					acTitle=getlocal("activity_lmqrj_title_v2")
				else
					acTitle=getlocal("activity_lmqrj_title")
				end
				tabTb={getlocal("activity_lmqrj_tabOne_title"),getlocal("activity_lmqrj_tabTwo_title")}
				self.openDialog=acLmqrjDialog:new(self.layerNum+1)
			elseif acVo.type=="thfb" then
				local openLv = acThfbVoApi:getLevelLimit()
				if acVo.version==1 then
					acTitle = getlocal("activity_thfb_title")
				else
					acTitle = getlocal("activity_thfb_v"..acVo.version.."_title")
				end
				if(playerVoApi:getPlayerLevel()<openLv)then
					smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_newyearseve_lvllack",{openLv}),30)
				else
					tabTb={getlocal("activity_thfb_subTitle_giftBag"),getlocal("activity_thfb_subTitle_task")}
					self.openDialog=acThfbDialog:new(self.layerNum+1)
				end
			elseif acVo.type == "xcjh" then
				local openLv = 1
				if(playerVoApi:getPlayerLevel()<openLv)then
					smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_newyearseve_lvllack",{openLv}),30)
				else
					if acXcjhVoApi and acXcjhVoApi:getVersion()==2 then
						acTitle = getlocal("activity_xcjh_title_v2")
						tabTb={getlocal("activity_xcjh_subTitle1_v2"),getlocal("activity_xcjh_subTitle2"),getlocal("activity_xcjh_subTitle3")}
						self.openDialog = acXcjhDialog:new(self.layerNum+1)
					else
						acTitle = getlocal("activity_xcjh_title")
						tabTb={getlocal("activity_xcjh_subTitle1"),getlocal("activity_xcjh_subTitle2"),getlocal("activity_xcjh_subTitle3")}
						self.openDialog = acXcjhDialog:new(self.layerNum+1)
					end
				end
			elseif acVo.type=="mjzy" then
				local openLv = acMjzyVoApi:getLevelLimit()
				acTitle = getlocal("activity_mjzy_title")
				if playerVoApi:getPlayerLevel() < openLv then
					smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_newyearseve_lvllack",{openLv}),30)
				else
					tabTb={getlocal("activity_mjzy_reinforce"),getlocal("acMayDay_tab2_title")}
					self.openDialog=acMjzyDialog:new(self.layerNum+1)
				end
			elseif acVo.type =="xlys" then
				local openLv = acXlysVoApi:getLevelLimit()
				acTitle = getlocal("activity_xlys_title")
				if playerVoApi:getPlayerLevel() < openLv then
					smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_newyearseve_lvllack",{openLv}),30)
				else
					tabTb={getlocal("emblem_troop_wash"),getlocal("activity_thfb_subTitle_task")}
					self.openDialog=acXlysDialog:new(self.layerNum+1)
				end
			elseif acVo.type=="ydcz" then
				acTitle=getlocal("activity_ydcz_title")
				self.openDialog=acYdczDialog:new()
			elseif acVo.type=="tqbj" then
				if acTqbjVoApi:getVersion()==7 then
					acTitle=getlocal("activity_tqbj_ver2_title")
				else
					acTitle=getlocal("activity_tqbj_title")
				end
				self.openDialog=acTqbjDialog:new()
			elseif acVo.type=="xstq" then
				acTitle=getlocal("activity_xstq_title")
				self.openDialog=acXstqDialog:new()
			elseif acVo.type=="smbd" then
				local openLv = acSmbdVoApi:getLevelLimit()
				acTitle = getlocal("activity_smbd_title")
				if(playerVoApi:getPlayerLevel()<openLv)then
					smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_newyearseve_lvllack",{openLv}),30)
				else
					tabTb={}
					self.openDialog=acSmbdDialog:new(self.layerNum+1)
				end
			elseif acVo.type == "hryx" then
				acTitle = getlocal("activity_hryx_title")
				tabTb={getlocal("activity_hryx_tab1"),getlocal("activity_hryx_tab2")}
				self.openDialog=acHryxDialog:new(self.layerNum+1)
			elseif acVo.type == "wxgx" then
				acTitle = getlocal("activity_wxgx_title")
				self.openDialog=acWxgxDialog:new()
			elseif acVo.type == "ryhg" then
				acTitle = getlocal("activity_ryhg_title")
				self.openDialog=acRyhgDialog:new()
			elseif acVo.type=="znjl" then
				if acZnjlVoApi and acZnjlVoApi:getVersion() == 2 then
					acTitle = getlocal("active_znsd_title")
					self.openDialog=acZnsdDialog:new()
				else
					acTitle = getlocal("activity_znjl_title")
					self.openDialog=acZnjlDialog:new()
				end
			elseif acVo.type == "znkh2018" then
				acTitle = getlocal("activity_znkh2018_title")
				tabTb = { getlocal("recharge"), getlocal("mainRank"), getlocal("activity_znkh2018_tab3Title") }
				self.openDialog = acZnkhFiveAnniversaryDialog:new(self.layerNum + 1)
			elseif acVo.type == "kfcz" then
				acTitle = getlocal("activity_kfcz_title")
				tabTb = { getlocal("recharge"), getlocal("mainRank"), getlocal("activity_znkh2018_tab3Title") }
				self.openDialog = acKfczDialog:new(self.layerNum + 1)
			elseif acVo.type == "zntp" then
				acTitle = getlocal("activity_zntp_title")
				self.openDialog = acZntpDialog:new(self.layerNum + 1)
			elseif acVo.type == "jtxlh" then
				acTitle = getlocal("activity_jtxlh_title")
				self.openDialog = acJtxlhDialog:new()
			elseif acVo.type == "znkh2019" then
				acTitle = getlocal("activity_znkh2019_title")
				local openLv = acZnkh19VoApi:getOpenLv()
				if(playerVoApi:getPlayerLevel() < openLv)then
					smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_newyearseve_lvllack",{openLv}),30)
				else
					tabTb = {getlocal("activity_loversDay_tab2"), getlocal("activity_wheelFortune_subTitle_1")}
					tabType = 1
					self.openDialog = acZnkh19Dialog:new()
				end
			elseif acVo.type == "hjld" then
				acTitle = getlocal("acMemoryServer_title")
				if G_isMemoryServer() then
					tabTb = { getlocal("acMemoryServer_tab1Title"), getlocal("acMemoryServer_tab2Title") }
				end
				self.openDialog = acMemoryServerDialog:new(self.layerNum + 1)
			elseif acVo.type == "xjlb" then
				if acCashGiftBagVoApi:isCanEnter() then
					acTitle = acCashGiftBagVoApi:getActiveTitle()
					self.openDialog = acCashGiftBagDialog:new(self.layerNum + 1)
				end
			else
				local arr=Split(acVo.type,"_")
			    if arr[1]== "buyreward" then
			    	acBuyrewardVoApi:setActiveName(acVo.type)
			    	acTitle =getlocal("activity_buyreward_title" .. acBuyrewardVoApi:getNameType())
					tabTb ={}
					self.openDialog=acBuyrewardDialog:new()
				elseif arr[1]== "pjjnh" then
					acPjjnhVoApi:setActiveName(acVo.type)
			    	acTitle =getlocal("activity_pjjnh_title")
					tabTb ={}
					self.openDialog=acPjjnhDialog:new()
				elseif arr[1]=="zjfb" then
					acArmoredStormVoApi:setActiveName(acVo.type)
					acTitle = getlocal("activity_zjfb_title")
					tabTb = {}
					self.openDialog = acArmoredStromDialog:new()
				elseif arr[1] =="olympic" then
					acOlympicVoApi:setActiveName(acVo.type)
					acTitle = getlocal("activity_olympic_title")
					tabTb ={}
					self.openDialog=acOlympicDialog:new()
				elseif arr[1] =="luckcard" then
					acLuckyPokerVoApi:setActiveName(acVo.type)
					acTitle =getlocal("activity_luckyPoker_title")
					if base.alien ==1 then
						tabTb ={getlocal("activity_wheelFortune_subTitle_1"),getlocal("activity_TitaniumOfharvest_tab3")}
						self.openDialog=acLuckyPokerFrameDialog:new()
					else
						tabTb ={}
						self.openDialog=acLuckyPokerDialog:new()
					end
				elseif arr[1] == "customLottery" then
					acCustomLotteryVoApi:setActiveName(acVo.type)
					acTitle =getlocal("activity_"..arr[1].."_title")
					tabTb ={}
					self.openDialog = acCustomLotteryDialog:new()
				elseif arr[1] == "gqkh" then
					acGqkhVoApi:setActiveName(acVo.type)
					if acGqkhVoApi:getAcShowType()==acGqkhVoApi.acShowType.TYPE_2 then
						acTitle=getlocal("activity_gqkh_title_1")
						tabTb ={getlocal("activity_gqkh_tab1_1"),getlocal("activity_gqkh_tab2_1")}
					else
						acTitle=getlocal("activity_gqkh_title")
					tabTb ={getlocal("activity_gqkh_tab1"),getlocal("activity_gqkh_tab2")}
					end
					self.openDialog = acGqkhDialog:new()
				elseif arr[1] == "wsjdzz2017" then
					acWsjdzzIIVoApi:setActiveName(acVo.type)
					if acWsjdzzIIVoApi:getVersion() == 2 or acWsjdzzIIVoApi:getVersion() == 4 then
						acTitle = getlocal("activity_wanshengjiedazuozhan_title_n")
					elseif acWsjdzzIIVoApi:getVersion() == 1 then
						acTitle = getlocal("activity_wsjdzz2017_title")
					elseif acWsjdzzIIVoApi:getVersion() == 3 then
						acTitle = getlocal("activity_wanshengjiedazuozhan_title_p") 
					end
					tabTb ={getlocal("activity_wheelFortune_subTitle_1"),getlocal("task")}
					self.openDialog = acWsjdzzIIDialog:new()
					tabInitIndex=0
				elseif arr[1] == "wsjdzz" then
					acWsjdzzVoApi:setActiveName(acVo.type)
					if(acWsjdzzVoApi:isNormalVersion(acVo.type))then
						acTitle = getlocal("activity_wanshengjiedazuozhan_title_n")
					else
						acTitle = getlocal("activity_wanshengjiedazuozhan_title")
					end
					tabTb ={getlocal("activity_wheelFortune_subTitle_1"),getlocal("task")}
					self.openDialog = acWsjdzzDialog:new()
					tabInitIndex=0
				elseif arr[1] == "openyear" then
					acOpenyearVoApi:setActiveName(acVo.type)
					if acOpenyearVoApi:getAcShowType()==acOpenyearVoApi.acShowType.TYPE_2 then
						acTitle = getlocal("activity_openyear_title_1")
					elseif acOpenyearVoApi:getAcShowType()==acOpenyearVoApi.acShowType.TYPE_3 then
						acTitle = getlocal("activity_openyear_title_3")
					else
						acTitle = getlocal("activity_openyear_title")
					end
					tabTb ={getlocal("activity_openyear_tab1"),getlocal("recharge"),getlocal("task")}
					self.openDialog = acOpenyearDialog:new()
					tabInitIndex=0
				elseif arr[1] == "btzx" then
					acBtzxVoApi:setActiveName(acVo.type)
					acTitle = getlocal("activity_btzx_title")
					tabTb ={getlocal("activity_btzx_tab1"),getlocal("activity_btzx_tab2")}
					self.openDialog = acBtzxDialog:new()
					tabInitIndex=0
				elseif arr[1] == "gej2016" then
					acGej2016VoApi:setActiveName(acVo.type)
					acTitle = getlocal("activity_gej2016_title")
					tabTb ={getlocal("activity_gej2016_tab1"),getlocal("activity_gej2016_tab2")}
					self.openDialog = acGej2016Dialog:new()
					tabInitIndex=0
				elseif arr[1] == "nljj" then
					acNljjVoApi:setActiveName(acVo.type)
					acTitle = getlocal("activity_nljj_title")
					tabTb ={getlocal("merge_btn"),getlocal("mainRank")}
					self.openDialog = acNljjDialog:new()
					tabInitIndex=0
				elseif arr[1] == "qxtw" then
					acQxtwVoApi:setActiveName(acVo.type)
					acTitle = getlocal("activity_qxtw_title")
					tabTb ={getlocal("activity_zhanshuyantao_ljAward1"),getlocal("activity_ganenjiehuikui_eveTask")}
					self.openDialog = acQxtwDialog:new()
					tabInitIndex=0
				elseif arr[1] == "zjjz" then
					acZjjzVoApi:setActiveName(acVo.type)
					acTitle = getlocal("activity_zjjz_title")
					tabTb ={}
					self.openDialog =acZjjzDialog:new()
					tabInitIndex=0
				elseif arr[1] == "xscj" then
					acXscjVoApi:setActiveName(acVo.type)
					acTitle = getlocal("activity_xscj_title")
					tabTb ={}
					self.openDialog =acXscjDialog:new()
					tabInitIndex=0
				elseif arr[1] == "xssd" then
					acXssdVoApi:setActiveName(acVo.type)
					acTitle = getlocal("activity_xssd_title")
					tabTb ={}
					self.openDialog =acXssdDialog:new()
					tabInitIndex=0
				elseif arr[1] == "wjdc" then
					-- acWjdcVoApi:setActiveName(acVo.type)
					acTitle = getlocal("activity_wjdc_title")
					tabTb ={}
					self.openDialog =acWjdcDialog:new()
					tabInitIndex=0
				elseif arr[1] == "znkh2017" then
					acZnkh2017VoApi:setActiveName(acVo.type)
					acTitle = getlocal("activity_znkh2017_title")
					tabTb ={getlocal("activity_znkh2017_tab1"),getlocal("activity_znkh2017_tab2"),getlocal("activity_znkh2017_tab3")}
					self.openDialog =acZnkh2017Dialog:new()
					tabInitIndex=0
				elseif arr[1] == "pjgx" then
					acPjgxVoApi:setActiveName(acVo.type)
					acTitle = getlocal("activity_pjgx_title")
					tabTb ={getlocal("activity_ganenjiehuikui_eveTask"),getlocal("activity_pjgx_tab2")}
					self.openDialog =acPjgxDialog:new()
					tabInitIndex=0
				elseif arr[1] == "tccx" then
					acTccxVoApi:setActiveName(acVo.type)
					acTitle = getlocal("activity_tccx_title")
					tabTb ={getlocal("startProduceProp"),getlocal("code_gift")}
					self.openDialog =acTccxDialog:new()
					tabInitIndex=0
				elseif arr[1] == "wmzz" then
					acWmzzVoApi:setActiveName(acVo.type)
					acTitle = getlocal("activity_wmzz_title")
					tabTb ={}
					self.openDialog =acWmzzDialog:new()
				elseif arr[1] == "yjtsg" then
					acYjtsgVoApi:setActiveName(acVo.type)
					acTitle = getlocal("activity_yjtsg_title")
					tabTb ={getlocal("activity_equipSearch_subTitle_1"),getlocal("smelt")}
					self.openDialog =acYjtsgDialog:new()
					-- tabInitIndex=0
				elseif arr[1] == "gzhx" then
					acGzhxVoApi:setActiveName(acVo.type)
					acTitle = getlocal("activity_gzhx_title")
					tabTb ={getlocal("activity_wheelFortune_subTitle_1"),getlocal("smelt")}
					self.openDialog =acGzhxDialog:new()
				elseif arr[1]=="cjms" then
					acSuperShopVoApi:setActiveName(acVo.type)
					acTitle=getlocal("activity_cjms_title")
					tabTb={getlocal("activity_cjms_tab1"),getlocal("activity_cjms_tab2")}
					self.openDialog=acSuperShopDialog:new()
				elseif arr[1]=="zjjy" then
					acArmorEliteVoApi:setActiveName(acVo.type)
					acTitle=getlocal("activity_zjjy_title")
					tabTb={}
					self.openDialog=acArmorEliteDialog:new()
				elseif arr[1]=="kzhd" then
					acKzhdVoApi:setActiveName(acVo.type)
					acTitle=getlocal("activity_kzhd_title")
					tabTb={getlocal("activity_shareHappiness_sub2_gift"),getlocal("activity_kzhd_tab2")}
					self.openDialog=acKzhdDialog:new()
				elseif arr[1]=="khzr" then
					acKhzrVoApi:setActiveName(acVo.type)
					acTitle=acKhzrVoApi:getVersion() == 1 and getlocal("activity_khzr_title") or getlocal("activity_khzr_title_v2")
					self.openDialog=acKhzrDialog:new()
				elseif arr[1]=="secretshop" then
					acSecretshopVoApi:setActiveName(acVo.type)
					acTitle=getlocal("activity_secretshop_title")
					tabTb={getlocal("activity_shareHappiness_sub2_gift"),getlocal("code_gift")}
					self.openDialog=acSecretshopDialog:new()
				elseif arr[1]=="znqd2017" then
			    	acAnniversaryFourVoApi:setActiveName(acVo.type)
			    	acTitle =getlocal("activity_znqd2017_title")
					tabTb={getlocal("activity_kzhd_tab2"),getlocal("recharge")}
					self.openDialog=acAnniversaryFourDialog:new()
				elseif arr[1]=="qmcj" then
					if playerVoApi:getPlayerLevel() < 30 then
						smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("expeditionNotEnough",{30}),30)
						do return end
					end
					acEatChickenVoApi:setActiveName(acVo.type)
					acTitle=getlocal("activity_qmcj_title")
					tabTb={getlocal("activity_qmcj_title_tab1"),getlocal("activity_qmcj_title_tab2")}
					self.openDialog=acEatChickenDialog:new()
				elseif arr[1]=="qmsd" then
					acQmsdVoApi:setActiveName(acVo.type)
					acTitle=getlocal("activity_qmsd_title")
					tabTb={getlocal("activity_qmsd_title_tab1"),getlocal("activity_qmsd_title_tab2"),getlocal("activity_qmsd_title_tab3")}
					self.openDialog=acQmsdDialog:new()
				elseif arr[1]=="mjzx" then
					if playerVoApi:getPlayerLevel() < 30 then
						smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("expeditionNotEnough",{30}),30)
						do return end
					end
					acMjzxVoApi:setActiveName(acVo.type)
					acTitle=getlocal("activity_mjzx_title")
					tabTb={getlocal("activity_mjzx_title_tab1"),getlocal("activity_mjzx_title_tab2")}
					self.openDialog=acMjzxDialog:new()
				elseif arr[1]=="yrj" then
					if playerVoApi:getPlayerLevel() < acYrjVoApi:getLimit( ) then
						smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("expeditionNotEnough",{acYrjVoApi:getLimit( )}),30)
						do return end
					end
					acYrjVoApi:setActiveName(acVo.type)
					if acYrjVoApi:getVersion() == 1 then
						acTitle=getlocal("activity_yrj_title")
					elseif acYrjVoApi:getVersion() == 2 then
						acTitle=getlocal("activity_yrjV2_title")
					end
					tabTb={getlocal("activity_yrj_title_tab1"),getlocal("activity_yrj_title_tab2")}
					self.openDialog=acYrjDialog:new()
				elseif arr[1]=="duanwu" then
					acDuanWuVoApi:setActiveName(acVo.type)
					if acDuanWuVoApi:getVersion() == 1 then
						acTitle=getlocal("activity_duanwu_title")
					else
						acTitle=getlocal("activity_duanwu2_title")
					end
					tabTb={getlocal("recharge"),getlocal("market")}
					self.openDialog=acDuanWuDialog:new()
				elseif arr[1]=="wpbd" then
					acWpbdVoApi:setActiveName(acVo.type)
			    	acTitle =getlocal("activity_wpbd_title")
					tabTb={getlocal("activity_wpbd_tab1"),getlocal("activity_wpbd_tab2")}
					self.openDialog=acWpbdDialog:new()
				elseif arr[1]=="dlbz" then
					if playerVoApi:getPlayerLevel() < acDlbzVoApi:getLimit() then
						smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("expeditionNotEnough",{acDlbzVoApi:getLimit()}),30)
						do return end
					end
					acDlbzVoApi:setActiveName(acVo.type)
					acTitle=getlocal("activity_dlbz_title")
					tabTb={}
					self.openDialog=acDlbzDialog:new()
				elseif arr[1]=="czhk" then
					acCzhkVoApi:setActiveName(acVo.type)
					acTitle=getlocal("activity_czhk_title")
					tabTb={}
					self.openDialog=acCzhkDialog:new()
				elseif arr[1]=="zncf" then
					if playerVoApi:getPlayerLevel() < acZncfVoApi:getLimit() then
						smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("expeditionNotEnough",{acZncfVoApi:getLimit()}),30)
						do return end
					end
					acZncfVoApi:setActiveName(acVo.type)
					acTitle=getlocal("activity_zncf_title")
					tabTb={}
					self.openDialog=acZncfDialog:new()
				elseif arr[1]=="xlpd" then
					if playerVoApi:getPlayerLevel() < acXlpdVoApi:getLimit() then
						smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("expeditionNotEnough",{acXlpdVoApi:getLimit()}),30)
						do return end
					end
					acXlpdVoApi:setActiveName(acVo.type)
					acTitle=getlocal("activity_xlpd_title")
					tabTb={}
					self.openDialog=acXlpdDialog:new()
				elseif arr[1]=="bhqf" then
					acBhqfVoApi:setActiveName(acVo.type)
			    	acTitle =getlocal("activity_bhqf_title")
					tabTb={getlocal("activity_bhqf_tab1"),getlocal("task")}
					self.openDialog=acBhqfDialog:new()
				elseif arr[1]=="cflm" then
					acCflmVoApi:setActiveName(acVo.type)
			    	acTitle =getlocal("activity_cflm_title")
					tabTb={getlocal("recharge"),getlocal("activity_cflm_invest")}
					self.openDialog=acCflmDialog:new()
				elseif arr[1]=="wsj2018" then
					if playerVoApi:getPlayerLevel() < acHalloween2018VoApi:getlevelLimit( ) then
						smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("expeditionNotEnough",{acHalloween2018VoApi:getlevelLimit( )}),30)
						do return end
					end
					acHalloween2018VoApi:setActiveName(acVo.type)
					local version = acHalloween2018VoApi:getVersion()
					if version==1 then
						acTitle=getlocal("activity_wsj2018_title")
					else
						acTitle=getlocal("activity_wsj2018_ver"..version.."_title")
					end
					tabTb={}
					self.openDialog=acHalloween2018Dialog:new()
				elseif arr[1] == "jblb" then
					if acCustomVoApi:isCanEnter(arr[2]) then
						acTitle = acCustomVoApi:getActiveTitle(arr[2])
						self.openDialog = acCustomDialog:new(self.layerNum + 1, arr[2])
					end
				elseif arr[1]=="gwkh" then
					acGwkhVoApi:setActiveName(acVo.type)
					acTitle=getlocal("activity_gwkh_title")
					self.openDialog=acGwkhDialog:new()
				elseif arr[1]=="mjcs" then
					acMjcsVoApi:setActiveName(acVo.type)
					local version = tonumber(acMjcsVoApi:getVersion())
					if version==1 then
						acTitle=getlocal("activity_mjcs_title")
					else
						acTitle=getlocal("activity_mjcs_title_v2")
					end
					tabTb={getlocal("activity_mjcs_tabOneTitle"),getlocal("activity_thfb_subTitle_task")}
					self.openDialog=acMjcsDialog:new()
				elseif arr[1]=="xssd2019" then
					acXssd2019VoApi:setActiveName(acVo.type)
					acTitle=getlocal("activity_xssd2019_title")
					tabTb={getlocal("activity_xssd2019_tab1"),getlocal("activity_xssd2019_tab2"),getlocal("activity_xssd2019_tab3")}
					self.openDialog=acXssd2019Dialog:new()
				elseif arr[1]=="jjzz" then
					acJjzzVoApi:setActiveName(acVo.type)
					acTitle=getlocal("activity_jjzz_title")
					tabTb={}
					self.openDialog=acJjzzDialog:new()
				elseif arr[1]=="nlgc" then
					acNlgcVoApi:setActiveName(acVo.type)
					acTitle=getlocal("activity_nlgc_title")
					tabTb={getlocal("ac_nlgc_tab1"),getlocal("ac_nlgc_tab2")}
					self.openDialog=acNlgcDialog:new()
			    end
			end
			
			if self.openDialog ~= nil then
				if acTitle == nil then
					acTitle = getlocal("activity_"..acVo.type.."_title")
				end
				local vd = self.openDialog:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tabTb,nil,nil,acTitle,true,self.layerNum + 1,nil,nil,tabType);
				if tabInitIndex ~= nil then
					self.openDialog:tabClick(tabInitIndex)
				end
				sceneGame:addChild(vd,self.layerNum + 1)
			end
		elseif self.selectedTabIndex==1 then
			local function openCallback(acType)
				-- if acType and acType=="dnews" then
				-- 	self:close()
				-- end
			end
			dailyActivityVoApi:showDialog(tag + 1,self.layerNum + 1,openCallback,true)
		else
			local noteVo = noteVoApi:getAllNote()[tag + 1]
			if noteVo ~= nil then
				local function openNoteDialog(fn,data)
					local ret,sData=base:checkServerData(data)
					if ret==true then
						if sData.data.nmsg ~= nil then
							noteVo:setDes(sData.data.nmsg)
							self:openNoteDialog(noteVo)
						end
					end
				end

				if noteVo.des == nil then
					socketHelper:noteRead(noteVo.id,openNoteDialog)
				else
					self:openNoteDialog(noteVo)
				end
			end
		end
	-- end
end

function activityAndNoteDialog:openNoteDialog(noteVo)
	if noteVo == nil then
		do return end
	end
	noteVo.read = true
    require "luascript/script/game/scene/gamedialog/activityAndNote/noteDetailDialog"
	local dd = noteDetailDialog:new(noteVo)
	local vd = dd:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,nil,nil,getlocal("note"),false,self.layerNum+1);
	sceneGame:addChild(vd,self.layerNum+1)
	noteVoApi:updateUserDefaultAfterRead(noteVo)
	self:updateNewNum() -- 更新
	local recordPoint = self.tv:getRecordPoint()
	self.tv:reloadData()
	self.tv:recoverToRecordPoint(recordPoint)
end

function activityAndNoteDialog:tick()
  if self == nil then
    return
  end
  if self.countNum and self.countNum>-1 then
      self.countNum=self.countNum+1
      if self.countNum>10 then
          if self.loadingLb then
              self.loadingLb:setString(getlocal("loadingfail"))
              self.loadingLb:setVisible(true)
          end
          self.countNum=-1
      end
  end

  if base.xstz == 1 and limitChallengeVoApi:refresh() == true and self.updateFlag == 0 then
  		self.updateFlag = 1
		self.oldTime = base.serverTime
  end
  if base.xstz == 1 and self.updateFlag == 1 and self.requestFlag == 0 then
		if base.serverTime - self.oldTime >= 10 then
			self.requestFlag = 1
			local function callback(fn,data)
				local ret,sData = base:checkServerData(data)
				if ret==true then  
					if sData and sData.data and sData.data.limittask then
						limitChallengeVoApi:updateData(sData.data.limittask)
						self.updateFlag = 0
						self.requestFlag = 0
						limitChallengeVo:setFlag(true)
					end
				end
			end
			socketHelper:xstzGetTask(callback)
		end
  end

  if base.xstz == 1 and self.refreshTimeTb then
  	for k,v in pairs(self.refreshTimeTb) do
  		if tolua.cast(self.refreshTimeTb[k],"CCLabelTTF") then
  			self.refreshTimeTb[k]:setString(limitChallengeVoApi:getTimeStr())
  		end
  	end
  end

  if self.selectedTabIndex == 0 then
    local acNum = SizeOfTable(activityVoApi:getAllActivity())
    if acNum ~= self.acNum then  -- 有活动开启或结束时刷新
      self.acNum = acNum
      activityVoApi:updateUserDefault()
      activityVoApi.newNum = activityVoApi:newAcNum()
      self:updateNewNum()
      self.lbTab={}
      self.nhtimeTb={}
	  local recordPoint = self.tv:getRecordPoint()
	  self.tv:reloadData()
	  self.tv:recoverToRecordPoint(recordPoint)
      self:updateOpenDialog()
    elseif activityVoApi:getOneChangeState() then
      self.lbTab={}
      self.nhtimeTb={}
	  local recordPoint = self.tv:getRecordPoint()
	  self.tv:reloadData()
	  self.tv:recoverToRecordPoint(recordPoint)
      self:updateOpenDialog()
    end
    --混服时间修改为倒计时
    if G_isGlobalServer()==true and self.lbTab then
    	for k,v in pairs(self.lbTab) do
    		if v and v.lb and v.vo then
    			local lb=tolua.cast(v.lb,"CCLabelTTF")
    			local acVo=v.vo
    			if lb and acVo and acVo.type~="ydcz" then
    				local timeStr=activityVoApi:getAcListShowTime(acVo)
					lb:setString(timeStr)
    			end
    		end
    	end
	end
	if self.nhtimeTb then
		local timeStr=""
		for k,v in pairs(self.nhtimeTb) do
			if v and v.lb then
				local timeLb=tolua.cast(v.lb,"CCLabelTTF")
				if k=="ydcz" and acYdczVoApi then --月度充值活动时间特殊处理
					timeStr=acYdczVoApi:getTimeStr()
				end
				timeLb:setString(timeStr)
			end
		end
	end
  elseif self.selectedTabIndex == 1 then
  	local acDailyNum = dailyActivityVoApi:canRewardNum()
  	if acDailyNum ~= self.acDailyNum then
  		self.acDailyNum = acDailyNum
  		self.dailyLbTab={}
		local recordPoint = self.tv:getRecordPoint()
		self.tv:reloadData()
		self.tv:recoverToRecordPoint(recordPoint)
  		if base.dailyAcYouhuaSwitch==1 then
			if acDailyNum>0 then
				self:setTipsVisibleByIdx(true,2,acDailyNum)
  			else
				self:setTipsVisibleByIdx(false,2)
			end 
		end
  	end
  	--混服时间修改为倒计时
  	if G_isGlobalServer()==true and self.dailyLbTab then
    	for k,v in pairs(self.dailyLbTab) do
    		if v and v.lb and v.vo then
    			local lb=tolua.cast(v.lb,"CCLabelTTF")
    			local acVo=v.vo
    			if lb and acVo then
    				local timeStr=G_getDailyActivityTimeShow(acVo)
					if timeStr and timeStr~="" then
						lb:setString(timeStr)
					end
    			end
    		end
    	end
	end
	if self.dailyLbTab then --刷新跟混服无关的倒计时
		for k,v in pairs(self.dailyLbTab) do
  			if v and v.lb and v.vo then
    			local lb=tolua.cast(v.lb,"CCLabelTTF")
    			local acVo=v.vo
    			if lb and acVo then
    				local timeStr
    				if acVo.type=="ydhk" then
						timeStr=dailyYdhkVoApi:getTimeStr()
    				end
    				if timeStr and timeStr~="" then
						lb:setString(timeStr)
					end
    			end
    		end
		end
	end
  else
    local noteNum = SizeOfTable(noteVoApi:getAllNote())
    if noteNum ~= self.noteNum then  -- 有公告开启或结束时刷新
      self.noteNum = noteNum
	  local recordPoint = self.tv:getRecordPoint()
	  self.tv:reloadData()
	  self.tv:recoverToRecordPoint(recordPoint)
    end
  end


   
  if self.selectedTabIndex == 1 then
	 self:updateReceiveReward1()
   	 self:updateReceiveReward2()
	  if receivereward1VoApi then
		  if receivereward1VoApi:getFlag()==true and self.drewNum1==false then
		  	dailyActivityVoApi:deleteActivityVo("drew1")	
		  	self.drewNum1=true
		  	receivereward1Vo:setReceive(true)
		  	self.dailyLbTab={}
			local recordPoint = self.tv:getRecordPoint()
			self.tv:reloadData()
			self.tv:recoverToRecordPoint(recordPoint)
		  	self.menuItemDesc1=nil
		  end
	  end

	  if receivereward2VoApi then
		  if receivereward2VoApi:getFlag()==true and self.drewNum2==false then
		  	dailyActivityVoApi:deleteActivityVo("drew2")	
		  	self.drewNum2=true
		  	receivereward2Vo:setReceive(true)
		  	self.dailyLbTab={}
			local recordPoint = self.tv:getRecordPoint()
			self.tv:reloadData()
			self.tv:recoverToRecordPoint(recordPoint)
		  	self.menuItemDesc2=nil
		  end
	  end
  end
  
end

function activityAndNoteDialog:updateReceiveReward1()
	if receivereward1VoApi then
		if receivereward1VoApi:checkShopOpen()==2 then
			if self and self.menuItemDesc1~=nil  then
				local spNormal = CCSprite:createWithSpriteFrameName("BtnOkSmall.png")
				spNormal:setAnchorPoint(ccp(1,0.5))
				self.menuItemDesc1:setNormalImage(spNormal)

				local spSelected = CCSprite:createWithSpriteFrameName("BtnOkSmall_Down.png")
				spSelected:setAnchorPoint(ccp(1,0.5))
				self.menuItemDesc1:setSelectedImage(spSelected)

				local spDisabled = CCSprite:createWithSpriteFrameName("BtnOkSmall.png")
				spDisabled:setAnchorPoint(ccp(1,0.5))
				self.menuItemDesc1:setDisabledImage(spDisabled)

				local label = GetTTFLabel(getlocal("daily_scene_get"),25)
				label:setPosition(ccp(self.menuItemDesc1:getContentSize().width/2,self.menuItemDesc1:getContentSize().height/2))
				self.menuItemDesc1:addChild(label)

				if self.menuItemFlag1== false then
					G_removeFlicker(self.menuItemDesc1)
					G_addRectFlicker(self.menuItemDesc1,2.2,0.95)
					self.menuItemFlag1 = true
				end

			end
		end
		if receivereward1VoApi:checkShopOpen()==false and self.drewNum1==false then
			dailyActivityVoApi:deleteActivityVo("drew1")	
		  	self.drewNum1=true
		  	receivereward1Vo:setReceive(true)
		  	self.dailyLbTab={}
			local recordPoint = self.tv:getRecordPoint()
			self.tv:reloadData()
			self.tv:recoverToRecordPoint(recordPoint)
		  	self.menuItemDesc1=nil
		end
	end
end

function activityAndNoteDialog:updateReceiveReward2()
	if receivereward2VoApi then
		if receivereward2VoApi:checkShopOpen()==2 then
			if self and self.menuItemDesc2~=nil  then
				local spNormal = CCSprite:createWithSpriteFrameName("newGreenBtn.png")
				spNormal:setAnchorPoint(ccp(1,0.5))
				self.menuItemDesc2:setNormalImage(spNormal)

				local spSelected = CCSprite:createWithSpriteFrameName("newGreenBtn_down.png")
				spSelected:setAnchorPoint(ccp(1,0.5))
				self.menuItemDesc2:setSelectedImage(spSelected)

				local spDisabled = CCSprite:createWithSpriteFrameName("newGreenBtn.png")
				spDisabled:setAnchorPoint(ccp(1,0.5))
				self.menuItemDesc2:setDisabledImage(spDisabled)

				local label = GetTTFLabel(getlocal("daily_scene_get"),25,true)
				label:setPosition(ccp(self.menuItemDesc2:getContentSize().width/2,self.menuItemDesc2:getContentSize().height/2))
				self.menuItemDesc2:addChild(label)

				self.menuItemDesc2:setScaleX(0.7)
				self.menuItemDesc2:setScaleY(0.8)
				label:setScaleX(1.3)
				label:setScaleY(1.2)

				-- self.menuItemDesc2:setAnchorPoint(ccp(0.5,0.5))
				if self.menuItemFlag2== false then
					G_removeFlicker(self.menuItemDesc2)
					G_addRectFlicker(self.menuItemDesc2,2.8,0.95)
					self.menuItemFlag2 = true
				end
				-- local ps = self.menuItemDesc2:getPosition()
				-- local size = self.menuItemDesc2:getContentSize()
				-- self.menuItemDesc2:setPosition(ccp(ps.x-size.width/2,ps.y))

			end
			
		end
		if receivereward2VoApi:checkShopOpen()==false and self.drewNum2==false then
			dailyActivityVoApi:deleteActivityVo("drew2")	
		  	self.drewNum2=true
		  	receivereward2Vo:setReceive(true)
		  	self.dailyLbTab={}
			local recordPoint = self.tv:getRecordPoint()
			self.tv:reloadData()
			self.tv:recoverToRecordPoint(recordPoint)
		  	self.menuItemDesc2=nil
		end
	end
end

function activityAndNoteDialog:updateOpenDialog()
  if self.openDialog ~= nil and self.openDialog.update ~= nil then
    self.openDialog:update()
  end
end

function activityAndNoteDialog:clearVar()
end

function activityAndNoteDialog:getIconFlicker(icon,m_iconScaleX,m_iconScaleY)
  return G_addFlicker(icon, 1/(m_iconScaleX/2), 1/(m_iconScaleY/2))
end

function activityAndNoteDialog:gotoAlliance(hadAlliance)
	activityAndNoteDialog:closeAllDialog()

  -- if hadAlliance ==false then
  --   require "luascript/script/game/scene/gamedialog/allianceDialog/allianceDialog"
  --   local td=allianceDialog:new(1,3)
  --   G_AllianceDialogTb[1]=td
  --   local tbArr={getlocal("alliance_list_scene_list"),getlocal("alliance_list_scene_create")}
  --   local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("alliance_list_scene_name"),true,3)
  --   sceneGame:addChild(dialog,3)
  -- else
  --   allianceEventVoApi:clear()
  --   require "luascript/script/game/scene/gamedialog/allianceDialog/allianceExistDialog"
  --   local td=allianceExistDialog:new(1,3)
  --   G_AllianceDialogTb[1]=td
  --   --[[
  --   local tbArr={getlocal("alliance_info_title"),getlocal("alliance_function"),getlocal("alliance_list_scene_list")}
  --   local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("alliance_list_scene_name"),true,3)
  --   sceneGame:addChild(dialog,3)
  --   td:tabClick(2)
  --   if td.playerTab3 ~= nil and base.isAllianceFubenSwitch==1 then
  --     td.playerTab3:tabClick(3)
  --   end
  --   ]]
  --   local td=allianceFuDialog:new(4)
  --     local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,nil,nil,getlocal("alliance_duplicate"),true,4)
  --     sceneGame:addChild(dialog,4)
  -- end
  allianceVoApi:showAllianceDialog(3)
end

function activityAndNoteDialog:closeAllDialog()
	--有些面板的close方法重写了，所以加了一个forceClose方法
  	for k,v in pairs(base.commonDialogOpened_WeakTb) do
  	  	local dialog = base.commonDialogOpened_WeakTb[k]
  	  	if(dialog and dialog.forceClose)then
  	  		dialog:forceClose()
  	  	elseif dialog ~= nil and dialog.close then
  	  	  	dialog:close()
  	  	end
  	end
  	while(#base.commonDialogOpened_WeakTb>0)do
  		local dialog=base.commonDialogOpened_WeakTb[1]
  		if(dialog and dialog.forceClose)then
  			dialog:forceClose()
  		elseif(dialog and dialog.close)then
  			dialog:close()
  		else
  			break
  		end
  	end
end

function activityAndNoteDialog:gotoByTag(tag, layerNum)
  local dlayerNum=3
    if tag==1 then
      --"研发科技"
      local bid=3
      local type=8
      local buildVo=buildingVoApi:getBuildiingVoByBId(bid)
      if buildVo and buildVo.status>0 then
        self:closeAllDialog()
        require "luascript/script/game/scene/gamedialog/portbuilding/techCenterDialog"
        local td=techCenterDialog:new(bid,dlayerNum,true)
        local bName=getlocal(buildingCfg[type].buildName)
        local tbArr={getlocal("building"),getlocal("startResearch")}
        local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,bName.."("..G_LV()..buildVo.level..")",true,dlayerNum)
        td:tabClick(1)
        sceneGame:addChild(dialog,dlayerNum)
      else
        local td=smallDialog:new()
        local tabStr = {"\n",getlocal("noBuilding",{getlocal("sample_build_name_08")}),"\n"}
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,layerNum+1,tabStr,28,nil)
        sceneGame:addChild(dialog,layerNum+1)
      end
    elseif tag==2 then
      --“建造坦克”
      local bid=11
      local type=6
      local buildVo=buildingVoApi:getBuildiingVoByBId(bid)
      if buildVo and buildVo.status>0 then
        self:closeAllDialog()
        require "luascript/script/game/scene/gamedialog/portbuilding/tankFactoryDialog"
        local td=tankFactoryDialog:new(bid,dlayerNum)
        local bName=getlocal(buildingCfg[type].buildName)
        local tbArr={getlocal("buildingTab"),getlocal("startProduce"),getlocal("chuanwu_scene_process")}
        local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,bName.."("..G_LV()..buildVo.level..")",true,dlayerNum)
        td:tabClick(1)
        sceneGame:addChild(dialog,dlayerNum)
      else
        local td=smallDialog:new()
        local tabStr = {"\n",getlocal("noBuilding",{getlocal("shipBuilding")}),"\n"}
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,layerNum + 1,tabStr,28,nil)
        sceneGame:addChild(dialog,layerNum + 1)
      end
    elseif tag==3 then
      self:closeAllDialog()
      --"提升统率"
      -- local td=playerDialog:new(1,dlayerNum,true)
      -- local tbArr={getlocal("playerInfo"),getlocal("skillTab"),getlocal("buildingTab")}
      -- local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("playerRole"),true,dlayerNum)
      -- td:tabClick(0)
      -- sceneGame:addChild(dialog,dlayerNum)
      local td=playerVoApi:showPlayerDialog(1,dlayerNum,true)
      td:tabClick(0)
    elseif tag==4 then
      self:closeAllDialog()
      --"提升技能"
      -- local td=playerDialog:new(2,dlayerNum,true)
      -- local tbArr={getlocal("playerInfo"),getlocal("skillTab"),getlocal("buildingTab")}
      -- local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("playerRole"),true,dlayerNum)
      -- td:tabClick(1)
      -- sceneGame:addChild(dialog,dlayerNum)
      local td=playerVoApi:showPlayerDialog(2,dlayerNum,true)
      td:tabClick(1)
    elseif tag==5 then
      self:closeAllDialog()
      -- 提升VIP
      -- require "luascript/script/game/scene/gamedialog/vipDialog"
      -- local vd1 = vipDialog:new()
      -- local vd = vd1:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,getlocal("vipTitle"),true,dlayerNum)
      -- sceneGame:addChild(vd,dlayerNum)
      vipVoApi:openVipDialog(dlayerNum)
    elseif tag == 6 then
      self:closeAllDialog()
      -- 指挥中心
      require "luascript/script/game/scene/gamedialog/portbuilding/commanderCenterDialog"
      local bid=1
      local bType=7
      local buildVo=buildingVoApi:getBuildiingVoByBId(bid)
      local td=commanderCenterDialog:new(bid)
      local bName=getlocal(buildingCfg[bType].buildName)
      local tbArr={getlocal("building"),getlocal("shuoming")}
      local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,bName.."("..G_LV()..buildVo.level..")",true)
      sceneGame:addChild(dialog,dlayerNum)
      
    elseif tag==7 then
      --“改装坦克”
      local bid=13
      local type=14
      local buildVo=buildingVoApi:getBuildiingVoByBId(bid)
      if buildVo and buildVo.status>0 then
        self:closeAllDialog()
        require "luascript/script/game/scene/gamedialog/portbuilding/tankTuningDialog"
        local td=tankTuningDialog:new(bid)
        local bName=getlocal(buildingCfg[type].buildName)
        local tbArr={getlocal("buildingTab"),getlocal("upgradeShip"),getlocal("chuanwu_scene_process")}
        local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,bName.."("..G_LV()..buildVo.level..")",true,3)
        td:tabClick(1)
        sceneGame:addChild(dialog,dlayerNum)
      else
        local td=smallDialog:new()
        local tabStr = {"\n",getlocal("noBuilding",{getlocal("sample_build_name_14")}),"\n"}
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,layerNum + 1,tabStr,28,nil)
        sceneGame:addChild(dialog,layerNum + 1)
      end

    elseif tag == 8 then
      self:closeAllDialog()
      local newGiftsState=newGiftsVoApi:hasReward()
      if newGiftsState ~=-1 then
          --七日登录送好礼
          require "luascript/script/game/scene/gamedialog/newGiftsDialog"
          local nd = newGiftsDialog:new()
          local tbArr={}
          local vd = nd:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("newGiftsTitle"),true)
          sceneGame:addChild(vd,3)
      end
    elseif tag == 9 then
      self:closeAllDialog()
      vipVoApi:showRechargeDialog(4)
    end
end

function activityAndNoteDialog:doUserHandler()
	if self.noAcTip ~= nil then
		self.noAcTip:setVisible(false)
	end
	if self.noNoteTip ~= nil then
		self.noNoteTip:setVisible(false)
	end

	if self.selectedTabIndex == 0 and activityVoApi.init == true then
		local acLen = SizeOfTable(activityVoApi:getAllActivity())
		if acLen == 0 then
			if self.noAcTip ~= nil then
				self.noAcTip:setVisible(true)
			else
				self.noAcTip = GetTTFLabelWrap(getlocal("noActivity"),40,CCSizeMake(G_VisibleSizeWidth - 60,200),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
				self.noAcTip:setAnchorPoint(ccp(0.5,0.5))
				self.noAcTip:setPosition(ccp(G_VisibleSizeWidth/2, G_VisibleSizeHeight/2))
				self.noAcTip:setColor(G_ColorYellowPro)
				self.bgLayer:addChild(self.noAcTip)
			end
		end
	elseif self.selectedTabIndex == 1 then
		local acLen = dailyActivityVoApi:getActivityNum()
		if(acLen==0)then
			if self.noAcTip ~= nil then
				self.noAcTip:setVisible(true)
			else
				self.noAcTip = GetTTFLabelWrap(getlocal("noActivity"),40,CCSizeMake(G_VisibleSizeWidth - 60,200),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
				self.noAcTip:setAnchorPoint(ccp(0.5,0.5))
				self.noAcTip:setPosition(ccp(G_VisibleSizeWidth/2, G_VisibleSizeHeight/2))
				self.noAcTip:setColor(G_ColorYellowPro)
				self.bgLayer:addChild(self.noAcTip)
			end
		end
	elseif self.selectedTabIndex == 2 and noteVoApi.init == true then
		local noteLen = SizeOfTable(noteVoApi:getAllNote())
		if noteLen == 0 then
			if self.noNoteTip ~= nil then
				self.noNoteTip:setVisible(true)
			else
				self.noNoteTip = GetTTFLabelWrap(getlocal("noNote"),24,CCSizeMake(G_VisibleSizeWidth - 60,150),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
				self.noNoteTip:setAnchorPoint(ccp(0.5,0.5))
				self.noNoteTip:setPosition(ccp(G_VisibleSizeWidth/2, G_VisibleSizeHeight/2))
				self.noNoteTip:setColor(G_ColorYellowPro)
				self.bgLayer:addChild(self.noNoteTip)
			end
		end
	end
end

--eventDispatcher的事件处理统一放在这个方法里面
function activityAndNoteDialog:eventListner(event,data)
	if(event=="activity.dialog.refresh")then
		if(data and data.type=="movgaBind")then
			if(self.tv and tolua.cast(self.tv,"LuaCCTableView"))then
	  			local recordPoint = self.tv:getRecordPoint()
	  			self.tv:reloadData()
	  			self.tv:recoverToRecordPoint(recordPoint)
			end
		end
	end
end

function activityAndNoteDialog:dispose()
	self.acNum = nil
	self.acDailyNum = nil
	self.noteNum = nil
	self.openDialog = nil -- 当前开着的活动面板
	self.noAcTip = nil
	self.noNoteTip = nil
	self.loadingLb = nil
	self.countNum = nil
	self.lbTab = nil
	self.dailyLbTab = nil
	self.nhtimeTb=nil
	self.refreshTimeTb = nil
	mainUI.dialog_acAndNote=nil
    eventDispatcher:removeEventListener("activity.dialog.refresh",self.refreshListener)
end

function activityAndNoteDialog:removeSpriteFrames()

    if base.boss == 1 then
	    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("ship/t99999Image.plist")
	    if G_isCompressResVersion()==true then
	    	CCTextureCache:sharedTextureCache():removeTextureForKey("ship/t99999Image.png")
	    else
	    	CCTextureCache:sharedTextureCache():removeTextureForKey("ship/t99999Image.pvr.ccz")
	    end
    end
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/Battleshow.jpg")
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/Battleshow1.jpg")
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/iconGoldImage.plist")
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/iconGoldImage.pvr.ccz")
	-- CCTextureCache:sharedTextureCache():dumpCachedTextureInfo()
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/slotMachine.plist")
	-- if G_WeakTb and (G_WeakTb.accessoryDialog or G_WeakTb.accessorySupplyDialog) then
	-- else
	-- 	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/accessoryImage.plist")
	-- 	if G_isCompressResVersion()==true then
	-- 		CCTextureCache:sharedTextureCache():removeTextureForKey("public/accessoryImage.png")
	-- 	else
	-- 		CCTextureCache:sharedTextureCache():removeTextureForKey("public/accessoryImage.pvr.ccz")
	-- 	end
	-- end
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/feeImage.plist")
  
    local DoorGhostVo = activityVoApi:getActivityVo("doorGhost")
    local ghostWarsVo = activityVoApi:getActivityVo("ghostWars")
    local JidongbuduiVo = activityVoApi:getActivityVo("jidongbudui")
    if JidongbuduiVo or DoorGhostVo then

        if G_curPlatName()=="13" or G_curPlatName()=="androidzhongshouyouko" or G_curPlatName()=="androidzsykonaver" or G_curPlatName()=="androidzsykoolleh" or G_curPlatName()=="androidzsykotstore" then
        CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("koImage/koAcIconImage.plist")
        CCTextureCache:sharedTextureCache():removeTextureForKey("koImage/koAcIconImage.pvr.ccz")
        end
    end
    if DoorGhostVo or ghostWarsVo then
        if DoorGhostVo then
            if G_curPlatName()=="0" or G_curPlatName()=="21" or G_curPlatName()=="androidarab" then
                CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/arabDoorGhost.plist")
                CCTextureCache:sharedTextureCache():removeTextureForKey("public/arabDoorGhost.pvr.ccz")
            end
        end
        CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acDoorGhost.plist")
    end
    local SinglesVo = activityVoApi:getActivityVo("singles")
    if SinglesVo  then
        --CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acSingles.plist")
    end

    if JidongbuduiVo  then
        if G_curPlatName()=="21" or G_curPlatName()=="androidarab" then
          CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/arabTurkeyImage.plist")
        end
        CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acJidongbudui.plist")
    end
    local BaifudaliVo = activityVoApi:getActivityVo("baifudali")
    if BaifudaliVo  then
        CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acBaifudali.plist")
    end

    local KuangnuVo = activityVoApi:getActivityVo("kuangnuzhishi")
	if KuangnuVo  then
        CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acKuangnuzhishi.plist")
    end
    
    local ZhenqinghuikuiVo = activityVoApi:getActivityVo("zhenqinghuikui")
	if ZhenqinghuikuiVo  then
        CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acZhenqinghuikui.plist")
        CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acYuanDanXianLi.plist")
        CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/jingDongCard.plist")
    end
    
    local ShengdanbaozangVo = activityVoApi:getActivityVo("shengdanbaozang")
	if ShengdanbaozangVo then
        CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acShengdanbaozang.plist")
		if(G_isArab() or G_curPlatName()=="0")then
			CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("arImage/acMysteriousArms_ar.plist")
			CCTextureCache:sharedTextureCache():removeTextureForKey("arImage/acMysteriousArms_ar.png")
		end        
        CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acMysteriousArms.plist")
    end
    
    local ShengdankuanghuanVo = activityVoApi:getActivityVo("shengdankuanghuan")
	if ShengdankuanghuanVo then
        CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acShengdankuanghuan.plist")
        CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acArsenalImage.plist")
    end
    local YuandanxianliVo = activityVoApi:getActivityVo("yuandanxianli")
    local HoldGroundVo = activityVoApi:getActivityVo("holdGround")
    local all = activityVoApi:getAllActivity()
    local luckcardFlag=false
	for k,v in pairs(all) do
		local arr=Split(v.type,"_")
		if arr[1]=="luckcard" then
			luckcardFlag=true
			break
		end
	end
	if YuandanxianliVo or HoldGroundVo or luckcardFlag then
        CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acYuanDanXianLi.plist")
    end

    local tankjianianhuaVo = activityVoApi:getActivityVo("tankjianianhua")
    if tankjianianhuaVo then
        CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acTankjianianhua.plist")
    end
    
    local xuyuanluVo = activityVoApi:getActivityVo("xuyuanlu")
    if xuyuanluVo then
        CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acXuyuanlu.plist")
    end
    
    local xinchunhongbaoVo = activityVoApi:getActivityVo("xinchunhongbao")
    if xinchunhongbaoVo then
        if G_curPlatName()=="0" or G_curPlatName()=="21" or G_curPlatName()=="androidarab" then
          CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/arabXinchunhongbao.plist")
          if G_isCompressResVersion()==true then
          	CCTextureCache:sharedTextureCache():removeTextureForKey("public/arabXinchunhongbao.png")
          else
          	CCTextureCache:sharedTextureCache():removeTextureForKey("public/arabXinchunhongbao.pvr.ccz")
          end
          
        end
        CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acXinchunhongbao.plist")
    end

    local equipSearchIIVo = activityVoApi:getActivityVo("equipSearchII")
	if equipSearchIIVo then
		if equipSearchIIVo.version and (equipSearchIIVo.version == 4 or equipSearchIIVo.version==5) then
			CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acKafukabaozang.plist")
		end
	end
	local mayDayVo = activityVoApi:getActivityVo("xingyunzhuanpan")
	if mayDayVo then
		CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acMayDayImage.plist")
		CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acMayDaySupply.plist")
	end
	local banzhangshilianVo = activityVoApi:getActivityVo("banzhangshilian")
	if banzhangshilianVo then
		CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("allianceWar/warMap.plist")
	end
	local kafkaGiftVo = activityVoApi:getActivityVo("kafkagift")
	local xiaofeisongliVo = activityVoApi:getActivityVo("xiaofeisongli")
	local acChongzhisongliVo = activityVoApi:getActivityVo("chongzhisongli")
	local acDanrichongzhiVo = activityVoApi:getActivityVo("danrichongzhi")
	local acDanrixiaofeiVo = activityVoApi:getActivityVo("danrixiaofei")
	local acThanksGivingVo = activityVoApi:getActivityVo("ganenjiehuikui")
	local acGeneralRecallVo = activityVoApi:getActivityVo("djrecall")
	if kafkaGiftVo or acChongzhisongliVo or acDanrichongzhiVo or acDanrixiaofeiVo or xiaofeisongliVo  or acThanksGivingVo or acGeneralRecallVo then
		-- CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acKafkaGift.plist")
		spriteController:removeTexture("public/acKafkaGift.pvr.ccz")
		spriteController:removePlist("public/acKafkaGift.plist")
	end
	local acHaoshichengshuangVo = activityVoApi:getActivityVo("haoshichengshuang")
	if acHaoshichengshuangVo then
		CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acHaoshichengshuang.plist")
	end
	local acXingyunpindianVo = activityVoApi:getActivityVo("xingyunpindian")
	local acRepublicHuiVo = activityVoApi:getActivityVo("republicHui")
	local acGqkhVo = activityVoApi:getActivityVo("gqkh")
	local acChristmasAttireVo=activityVoApi:getActivityVo("christmas2016")
	if acXingyunpindianVo or acRepublicHuiVo or acGqkhVo or acChristmasAttireVo then
		CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acRepublicHui.plist")
	end
    if acChristmasAttireVo then
  	    spriteController:removePlist("public/acChristmas2016_images.plist")
	    spriteController:removeTexture("public/acChristmas2016_images.png")
    end
	
	local acChrisEveVo = activityVoApi:getActivityVo("shengdanqianxi")
    local acBenfuqianxianVo = activityVoApi:getActivityVo("benfuqianxian")
	if acChrisEveVo or acBenfuqianxianVo or acChristmasAttireVo then
		spriteController:removePlist("public/acChrisEveImage.plist")
		spriteController:removeTexture("public/acChrisEveImage.png")
	end
	if(acChrisEveVo)then
		spriteController:removePlist("public/acChrisEveImage2.plist")
		spriteController:removeTexture("public/acChrisEveImage2.png")
	end

	CCTextureCache:sharedTextureCache():removeTextureForKey("public/slotMachine.pvr.ccz")
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/feeImage.pvr.ccz")
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/acDoorGhost.pvr.ccz")
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/acSingles.pvr.ccz")
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/acJidongbudui.pvr.ccz")
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/arabTurkeyImage.pvr.ccz")
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/acBaifudali.pvr.ccz")
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/acZhenqinghuikui.pvr.ccz")
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/acShengdanbaozang.pvr.ccz")
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/acShengdankuanghuan.pvr.ccz")
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/acArsenalImage.pvr.ccz")
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/acYuanDanXianLi.pvr.ccz")
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/acTankjianianhua.pvr.ccz")
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/acXuyuanlu.pvr.ccz")
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/acXinchunhongbao.pvr.ccz")
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/acKafukabaozang.pvr.ccz")
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/acMysteriousArms.pvr.ccz")
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/acMayDayImage.pvr.ccz")
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/acMayDaySupply.pvr.ccz")
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/expeditionImage.png")
	CCTextureCache:sharedTextureCache():removeTextureForKey("allianceWar/warMap.pvr.ccz")

	if G_isCompressResVersion()==true then
		CCTextureCache:sharedTextureCache():removeTextureForKey("public/slotMachine.png")
		CCTextureCache:sharedTextureCache():removeTextureForKey("public/feeImage.png")
		CCTextureCache:sharedTextureCache():removeTextureForKey("public/acDoorGhost.png")
		CCTextureCache:sharedTextureCache():removeTextureForKey("public/acJidongbudui.png")
		CCTextureCache:sharedTextureCache():removeTextureForKey("public/acBaifudali.png")
		CCTextureCache:sharedTextureCache():removeTextureForKey("public/acShengdanbaozang.png")
		CCTextureCache:sharedTextureCache():removeTextureForKey("public/acArsenalImage.png")
		CCTextureCache:sharedTextureCache():removeTextureForKey("public/acMysteriousArms.png")
		CCTextureCache:sharedTextureCache():removeTextureForKey("public/acMayDayImage.png")
		CCTextureCache:sharedTextureCache():removeTextureForKey("public/expeditionImage.png")
		CCTextureCache:sharedTextureCache():removeTextureForKey("allianceWar/warMap.png")
	end

	local acFirstRechargenewVo = activityVoApi:getActivityVo("firstRechargenew")
	local acFightRanknewVo = activityVoApi:getActivityVo("fightRanknew")
	local acChallengeranknewVo = activityVoApi:getActivityVo("challengeranknew")
    local acLuckyCatVo = activityVoApi:getActivityVo("xinfulaba")
	local acChristmasFightVo = activityVoApi:getActivityVo("christmasfight")
    local acMingjiangzailinVo = activityVoApi:getActivityVo("mingjiangzailin")
    local acNewYearVo = activityVoApi:getActivityVo("newyeargift")
    local acChrisEvVo = activityVoApi:getActivityVo("shengdanqianxi")
    local acChunjiepanshengVo = activityVoApi:getActivityVo("chunjiepansheng")
    local acNewYearsEveVo = activityVoApi:getActivityVo("newyeareva")
    local acStormFortressVo = activityVoApi:getActivityVo("stormFortress")
    local acRechargeBagVo = activityVoApi:getActivityVo("rechargebag")
    local acOlympicCollectVo=activityVoApi:getActivityVo("aoyunjizhang")
	local acMidAutumnVo=activityVoApi:getActivityVo("midautumn")
	local acThreeYearVo=activityVoApi:getActivityVo("threeyear")
	local acMineExploreVo=activityVoApi:getActivityVo("mineExplore")
	local acMineExploreGVo=activityVoApi:getActivityVo("mineExploreG")
	local acCjyxVo=activityVoApi:getActivityVo("cjyx")
	if acCjyxVo then
		spriteController:removePlist("public/acChrisEveImage.plist")
		spriteController:removeTexture("public/acChrisEveImage.png")
        CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acWanshengjiedazuozhan2.plist")
        CCTextureCache:sharedTextureCache():removeTextureForKey("public/acWanshengjiedazuozhan2.png")
	end
	if acThreeYearVo or acGeneralRecallVo then
	    spriteController:removePlist("public/acthreeyear_images.plist")
    	spriteController:removeTexture("public/acthreeyear_images.png")
	end
    if acOlympicCollectVo then
        if G_curPlatName()=="59" or G_curPlatName()=="13" or G_curPlatName()=="androidzhongshouyouko" or G_curPlatName()=="androidzsykonaver" or G_curPlatName()=="androidzsykoolleh" or G_curPlatName()=="androidzsykotstore" or G_isKakao()==true or G_curPlatName()=="androidcmge" then
	  		spriteController:removePlist("public/olympic_icon_korea.plist")
    		spriteController:removeTexture("public/olympic_icon_korea.png")
        end
    	spriteController:removePlist("public/acOlympicImage.plist")
    	spriteController:removeTexture("public/acOlympicImage.png")
    end
    if acMidAutumnVo then
	    spriteController:removePlist("public/acmidautumn_images.plist")
	    spriteController:removeTexture("public/acmidautumn_images.png")
    end
    if acMineExploreVo or acMineExploreGVo then
	    spriteController:removePlist("public/acMineExplore_images.plist")
	    spriteController:removeTexture("public/acMineExplore_images.png")
    end
 --    if acStormFortressVo then
	-- 	spriteController:removePlist("public/acStormFortressImage/acStormFortressImage.plist")
	-- 	spriteController:removeTexture("public/acStormFortressImage/acStormFortressImage.png")
	-- end
    local acRechargeGameVo = activityVoApi:getActivityVo("rechargeCompetition")
    if acChunjiepanshengVo then
    	local version = acChunjiepanshengVoApi:getVersion()
    	if version and version==3 then
    		spriteController:removePlist("public/acChunjiepansheng"..version..".plist")
			spriteController:removeTexture("public/acChunjiepansheng"..version..".png")
    	else
	    	spriteController:removePlist("public/acChunjiepansheng.plist")
	    	spriteController:removeTexture("public/acChunjiepansheng.png")
	    end
	    if version and version==4 then
	    	spriteController:removePlist("public/acChunjiepansheng4.plist")
	    	spriteController:removeTexture("public/acChunjiepansheng4.png")
	    end
    end

    if acRechargeBagVo then
		spriteController:removePlist("public/acRechargeBag_images.plist")
		spriteController:removeTexture("public/acRechargeBag_images.png")
		spriteController:removePlist("public/acNewYearsEva.plist")
    	spriteController:removeTexture("public/acNewYearsEva.png")
      	spriteController:removePlist("public/dimensionalWar/dimensionalWar.plist")
        spriteController:removeTexture("public/dimensionalWar/dimensionalWar.png")
    end
    
    if(acNewYearsEveVo) or acRechargeBagVo or acBenfuqianxianVo then
    	spriteController:removePlist("public/acChunjiepansheng.plist")
    	spriteController:removeTexture("public/acChunjiepansheng.png")
    end

    if acBenfuqianxianVo then
		spriteController:removePlist("public/acNewYearsEva.plist")
    	spriteController:removeTexture("public/acNewYearsEva.png")
	    spriteController:removePlist("public/acRadar_images.plist")
	    spriteController:removeTexture("public/acRadar_images.png")
    end

    local acFeixutansuoVo = activityVoApi:getActivityVo("feixutansuo")
	if acFirstRechargenewVo or acFightRanknewVo or acChallengeranknewVo or acLuckyCatVo or acMingjiangzailinVo or acChristmasFightVo or acNewYearVo or acChunjiepanshengVo or acRechargeGameVo or acFeixutansuoVo or acBenfuqianxianVo or acOlympicCollectVo or acMidAutumnVo then
		CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acFirstRechargenew.plist")
		CCTextureCache:sharedTextureCache():removeTextureForKey("public/acFirstRechargenew.png")
	end

	local acWanshengjiedazuozhanVo = activityVoApi:getActivityVo("wanshengjiedazuozhan")
	if acWanshengjiedazuozhanVo then
		local version=acWanshengjiedazuozhanVo.version
		if version and version>1 then
			CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acWanshengjiedazuozhan"..version..".plist")
			CCTextureCache:sharedTextureCache():removeTextureForKey("public/acWanshengjiedazuozhan"..version..".png")
		else
			CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acWanshengjiedazuozhan.plist")
			CCTextureCache:sharedTextureCache():removeTextureForKey("public/acWanshengjiedazuozhan.png")
		end
	end
	local acGej2016Vo = activityVoApi:getActivityVo("gej2016")
	if acGej2016Vo then
		spriteController:removePlist("public/acGej2016Image.plist")
	    spriteController:removeTexture("public/acGej2016Image.png")
	end
	-- 管理工具的万圣节大作战2017
	local acWsjdzzVo = activityVoApi:getActivityVo("wsjdzz")
	-- 管理工具万圣节大作战2
	local acWsjdzzIIVo = activityVoApi:getActivityVo("wsjdzz2017")
	if acWsjdzzVo or acWsjdzzIIVo then
		if acWsjdzzVo then
			CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acWanshengjiedazuozhan.plist")
			CCTextureCache:sharedTextureCache():removeTextureForKey("public/acWanshengjiedazuozhan.png")
		end
		CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/platWar/platWarImage.plist")
	    CCTextureCache:sharedTextureCache():removeTextureForKey("public/platWar/platWarImage.png")
        spriteController:removePlist("public/taskYouhua.plist")
        spriteController:removeTexture("public/taskYouhua.png")
	end
	if acWsjdzzIIVo then
		CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acWsjdzzIIImage.plist")
		CCTextureCache:sharedTextureCache():removeTextureForKey("public/acWsjdzzIIImage.png")
        spriteController:removePlist("public/wsjdzzV3.plist")
        spriteController:removeTexture("public/wsjdzzV3.png")
	end

	local acOpenyearVo = activityVoApi:getActivityVo("openyear")
	if acOpenyearVo then
		CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/platWar/platWarImage.plist")
	    CCTextureCache:sharedTextureCache():removeTextureForKey("public/platWar/platWarImage.png")
	    spriteController:removePlist("public/acOpenyearImage.plist")
	    spriteController:removeTexture("public/acOpenyearImage.png")
	end
	local acBtzxVo = activityVoApi:getActivityVo("btzx")
	if acBtzxVo then
		spriteController:removePlist("public/acBtzxImage.plist")
	    spriteController:removeTexture("public/acBtzxImage.png")
	end

	local acTankBattleVo = activityVoApi:getActivityVo("tankbattle")
	if acTankBattleVo then
		CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acTankBattle.plist")
	end
	local acImminentVo = activityVoApi:getActivityVo("yichujifa")
	local acNewYearVo = activityVoApi:getActivityVo("newyeargift")
	local acGqkhVo = activityVoApi:getActivityVo("gqkh")
	if acImminentVo or acNewYearVo then
        CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acImminentImage/acImminentImage.plist")
        CCTextureCache:sharedTextureCache():removeTextureForKey("public/acImminentImage/acImminentImage.png")

		spriteController:removePlist("serverWar/serverWar.plist")
		spriteController:removeTexture("serverWar/serverWar.pvr.ccz")
     end
     if acGqkhVo then
     	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/platWar/platWarImage.plist")
	    CCTextureCache:sharedTextureCache():removeTextureForKey("public/platWar/platWarImage.png")
	    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acCnNewYearImage/acCnNewYearImage.plist")
		CCTextureCache:sharedTextureCache():removeTextureForKey("public/acCnNewYearImage/acCnNewYearImage.png")
		CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acFirstRechargenew.plist")
		CCTextureCache:sharedTextureCache():removeTextureForKey("public/acFirstRechargenew.png")
		spriteController:removePlist("public/acGqkh.plist")
	    spriteController:removeTexture("public/acGqkh.png")
     end
	if acChristmasFightVo or acChrisEvVo or acChunjiepanshengVo or acNewYearsEveVo or acStormFortressVo  then
	    if(acChristmasFightVo) or (acNewYearsEveVo)  then
			CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/platWar/platWarImage.plist")
		    CCTextureCache:sharedTextureCache():removeTextureForKey("public/platWar/platWarImage.png")
		end
		spriteController:removePlist("public/acChrisEveImage.plist")
		spriteController:removeTexture("public/acChrisEveImage.png")
	end
	local acDouble11Vo = activityVoApi:getActivityVo("double11")
	local acDouble11NewVo = activityVoApi:getActivityVo("double11new")
	if (acDouble11Vo and acDouble11Vo.version and acDouble11Vo.version==2) or (acDouble11NewVo and  acDouble11NewVo.version and acDouble11NewVo.version==2) then
    	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acCnNewYearImage/acCnNewYearImage.plist")
		CCTextureCache:sharedTextureCache():removeTextureForKey("public/acCnNewYearImage/acCnNewYearImage.png")

    end
    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acItemBg.plist")
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/acItemBg.png")

    if acNewYearsEveVo or acStormFortressVo then
	    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("ship/t99998Image.plist")
	    if G_isCompressResVersion()==true then
	    	CCTextureCache:sharedTextureCache():removeTextureForKey("ship/t99998Image.png")
	    else
	    	CCTextureCache:sharedTextureCache():removeTextureForKey("ship/t99998Image.pvr.ccz")
	    end
        CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acWanshengjiedazuozhan2.plist")
        spriteController:removePlist("public/acNewYearsEva.plist")
        spriteController:removeTexture("public/acNewYearsEva.png")
    	spriteController:removePlist("public/acLuckyCat.plist")
    end

	local acAnniversaryBlessVo = activityVoApi:getActivityVo("anniversaryBless")
	local acBlessingWheelVo = activityVoApi:getActivityVo("blessingWheel")
	local all = activityVoApi:getAllActivity()
	local luckcardFlag=false
    local olympicFlag = false
    local jblbFlag = false
	for k,v in pairs(all) do
		local arr=Split(v.type,"_")
		if arr[1]=="luckcard" then
			luckcardFlag=true
		elseif arr[1] =="olympic" then
			olympicFlag =true
		elseif arr[1] == "jblb" then
			jblbFlag = true
		end
	end

    if acAnniversaryBlessVo or acBlessingWheelVo or luckcardFlag or olympicFlag then
	    spriteController:removePlist("public/acBlessWords.plist")
    end
    if olympicFlag then
        if G_curPlatName()=="59" or G_curPlatName()=="13" or G_curPlatName()=="androidzhongshouyouko" or G_curPlatName()=="androidzsykonaver" or G_curPlatName()=="androidzsykoolleh" or G_curPlatName()=="androidzsykotstore" or G_isKakao()==true or G_curPlatName()=="androidcmge" then
	  		spriteController:removePlist("public/olympic_icon_korea.plist")
    		spriteController:removeTexture("public/olympic_icon_korea.png")
        end
    	spriteController:removePlist("public/acOlympicImage.plist")
    	spriteController:removeTexture("public/acOlympicImage.png")
    end
    local acMonthlySignVo=activityVoApi:getActivityVo("monthlysign")
    if(acMonthlySignVo)then
    	spriteController:removePlist("public/acMonthlySign.plist")
    	spriteController:removeTexture("public/acMonthlySign.png")
    end
    local acAntiAirVo=activityVoApi:getActivityVo("battleplane")
    if(acAntiAirVo)then
		spriteController:removePlist("public/acAntiAir.plist")
		spriteController:removeTexture("public/acAntiAir.png")
    end    
    if acGeneralRecallVo then
    	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/platWar/platWarImage.plist")
    end
    local acSdzsVo=activityVoApi:getActivityVo("sdzs")
    if acSdzsVo then
    	spriteController:removePlist("public/serverWarLocal/serverWarLocalCommon.plist")
    	spriteController:removeTexture("public/serverWarLocal/serverWarLocalCommon.png")
    end

    local acFyssVo = activityVoApi:getActivityVo("fuyunshuangshou")
	if acFyssVo then
		spriteController:removePlist("public/acOpenyearImage.plist")
	    spriteController:removeTexture("public/acOpenyearImage.png")
	end

	local acZnkhVo = activityVoApi:getActivityVo("znkh")
	if acZnkhVo then
		spriteController:removePlist("public/acZnkhImage.plist")
	    spriteController:removeTexture("public/acZnkhImage.png")
	end

	local acThfbVo = activityVoApi:getActivityVo("thfb")
	local acNewDoubleOneVo = activityVoApi:getActivityVo("new112018")
	if acThfbVo or acNewDoubleOneVo then
		spriteController:removePlist("public/acThfb.plist")
	end
	if acThfbVo then
		spriteController:removePlist("public/acDouble11_NewImage.plist")
		spriteController:removeTexture("public/acDouble11_NewImage.png")
		spriteController:removePlist("public/packsImage.plist")
		spriteController:removeTexture("public/taskYouhua.png")
		
		spriteController:removePlist("public/taskYouhua.plist")
	    spriteController:removeTexture("public/packsImage.png")
	    spriteController:removeTexture("public/acThb.png")
	end

	local acMjzyVo = activityVoApi:getActivityVo("mjzy")

	if acMjzyVo then
		spriteController:removePlist("public/taskYouhua.plist")
	    spriteController:removeTexture("public/taskYouhua.png")
		spriteController:removePlist("public/acmjzy.plist")
		spriteController:removeTexture("public/acmjzy.png")
		spriteController:removePlist("public/acMjzxImage.plist")
		spriteController:removePlist("public/youhuaUI4.plist")
	    spriteController:removeTexture("public/acMjzxImage.png")
	    spriteController:removeTexture("public/youhuaUI4.png")
	end

	local acXlysVo = activityVoApi:getActivityVo("xlys")
	if acXlysVo then
		spriteController:removeTexture("public/acXlys.png")
		spriteController:removePlist("public/acXlys.plist")
	end

	local acSmbdVo = activityVoApi:getActivityVo("smbd")
	if acSmbdVo  then
		spriteController:removePlist("public/smbdPic.plist")
		spriteController:removeTexture("public/smbdPic.png")
	end
	
	local acLmqrjVo = activityVoApi:getActivityVo("lmqrj")
	if acLmqrjVo then
		spriteController:removePlist("public/acLmqrjImage.plist")
	    spriteController:removeTexture("public/acLmqrjImage.png")
	    if acLmqrjVoApi and acLmqrjVoApi:getVersion()==2 then
	    	spriteController:removePlist("public/acLmqrjImage2.plist")
	    	spriteController:removeTexture("public/acLmqrjImage2.png")
	    end
	end
	local yrjVo = activityVoApi:getActivityVo("yrj")
	if yrjVo then
		spriteController:removePlist("public/yrjV2.plist")
    	spriteController:removeTexture("public/yrjV2.png")
		spriteController:removePlist("public/acYrjImage.plist")
	    spriteController:removeTexture("public/acYrjImage.png")
	end

	if jblbFlag then
		spriteController:removePlist("public/acCustomImage.plist")
    	spriteController:removeTexture("public/acCustomImage.png")
	end

	local acXJlbVo = activityVoApi:getActivityVo("xjlb")
	if acXJlbVo then
		spriteController:removePlist("public/acXjlbImages.plist")
    	spriteController:removeTexture("public/acXjlbImages.png")
	end

    activityVoApi:addOrRemvoeIcon(2)
    dailyActivityVoApi:addOrRemvoeIcon(2)
end