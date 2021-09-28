--require "src/young/mydebug"
COMMONPATH = "res/common/" --公用图片地址
clickX , clickY = 0 , 0   --_CB按钮点击坐标

display = { width =  g_scrSize.width , height = g_scrSize.height , cx = g_scrSize.width/2 , cy = g_scrSize.height/2 }

--获取当前运行场景
function getRunScene()
  return (G_MAINSCENE and G_MAINSCENE.base_node) or (Director:getRunningScene())
end
--table长度
function tablenums(t)
    local count = 0
    for k, v in pairs(t) do
        count = count + 1
    end
    return count
end

function setNodeAttr(node,...)
	if not node then
		return
	end
	-- 1、pos 2、anchor 3、zOrder 4、tag 5、fScale
	local switch = {
		[1] = function(pos)
			node:setPosition(pos)
		end,
		[2] = function(anchor)
			node:setAnchorPoint(anchor)
		end,
		[3] = function(zOrder)
			node:setLocalZOrder(zOrder)
		end,
		[4] = function(tag)
			node:setTag(tag)
		end,
		[5] = function(scale)
			node:setScale(scale)
		end,
	}
	local Attrs = {...}
	for k,v in pairs(Attrs) do
		switch[k](v)
	end
end

function getSpriteFrame(frameName)
	return cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName)
end

function createMainUiNode(parent,order)
	local node = createSprite(parent,getSpriteFrame("mainui/netstatus/2g.png"),cc.p(0,0),cc.p(0.5,0.5),order)
	node:setTextureRect(cc.rect(0,0,1,1))
	return node
end

function createSprite(parent, pszFileName, pos, anchor, zOrder, fScale)
	local retSprite = nil
	if type(pszFileName) == "string" then
		retSprite = cc.Sprite:create(pszFileName)
	elseif pszFileName then
		retSprite = cc.Sprite:createWithSpriteFrame(pszFileName)
	else
		retSprite = cc.Sprite:create()
	end
	-- log(pszFileName)
	if retSprite then
		setNodeAttr(retSprite, pos, anchor, zOrder,nil, fScale)
		if parent then
			parent:addChild(retSprite)
		end
	end
	return retSprite
end

function createGraySprite(parent, res, pos, anchor, isGray)
   	local graySpr = GraySprite:create(res)
   	parent:addChild(graySpr)
   	graySpr:setAnchorPoint(anchor)
   	graySpr:setPosition(pos)
   	if isGray then
   		graySpr:addColorGray()
   	end
 	return graySpr
end

function getMemNameInTeam(sid)
    if G_TEAM_INFO and G_TEAM_INFO.team_data then
        for k,v in pairs(G_TEAM_INFO.team_data) do
            if v.roleId == sid then
                return v.name
            end
        end
    end 
    return nil
end

function getMapInfoData(mapId)
    local mapinfo = require("src/config/MapInfo")
    for k,v in pairs(mapinfo) do
        if v.q_map_id == mapId then
            return v
        end
    end
    return nil
end

function createMenuItem(parent, pszFileName, pos, callback,zorder,noswan,noDefaultVoice)
	if not parent then
		return
	end

	local futil = cc.FileUtils:getInstance()
	local bCurFilePopupNotify = false
	if isWindows() then
		bCurFilePopupNotify = futil:isPopupNotify()
		futil:setPopupNotify(false)
	end

	local select_filename = string.gsub(pszFileName,".png","_sel.png")
	if not futil:isFileExist(select_filename) then
		select_filename = nil
	end
	local dis_filename = string.gsub(pszFileName,".png","_gray.png")
	if not futil:isFileExist(dis_filename) then
		dis_filename = nil
	end

	if isWindows() then
		futil:setPopupNotify(bCurFilePopupNotify)
	end

	local menu_item = MenuButton:create(pszFileName,select_filename,dis_filename)
	local menu = cc.Menu:create()
	if zorder then
		parent:addChild(menu,zorder)
	else
		parent:addChild(menu)
	end
	menu:setPosition(0,0)
	if menu_item then
		menu:addChild(menu_item)
		menu:setTag(1)
		menu_item:setPosition(pos)
		if callback then
			menu_item:registerScriptTapHandler(function( targetID , node )
		  		local point = cc.p( node:getPosition() )
		      	local addr = node:getParent():convertToWorldSpace( point )
		      	clickX , clickY = addr.x  , addr.y
		      	if not noswan then node:setEnabled(false) end
		  		local cb = function()
		  			local node = tolua.cast(node,"MenuButton")
		  			if node and (not noswan) then
		  				node:setEnabled(true)
		  			end
		  		end
		  		performWithDelay(node,cb,0.15)
		  		callback( targetID ,node)
		  		if not noDefaultVoice then
		  			AudioEnginer.playTouchPointEffect()
		  		end
			end )
		end
	end
	return menu_item
end

function addLableToMenuItem(menu_item,content,fsize,color)
	local rt= menu_item:getContentSize()
	local fsize = fsize or 20
	local color = color or cc.c3b(255,255,255)
	local mlable = createLabel(menu_item,content,cc.p(rt.width/2,rt.height/2),nil,fsize,true)
	if mlable then
		mlable:setColor(color)
	end
	return mlable
end

function createTouchItem(parent, pszFileName, pos, callback,action,downFunc,noDefaultVoice)
	local func = function(targetID ,sender) 
		local sender = tolua.cast(sender,"TouchSprite")
		local cb = function()
			local sender = tolua.cast(sender,"TouchSprite")
			if sender then
				sender:setTouchEnable(true)
			end
		end
		if action then
			local actions = {cc.ScaleTo:create(0.15,0.85),cc.ScaleTo:create(0.05,1.0)}
			sender:runAction(cc.Sequence:create(actions))
		end
		performWithDelay(sender,cb,0.15)
		sender:setTouchEnable(false)
		callback(sender)
		if not noDefaultVoice then
			AudioEnginer.playTouchPointEffect()
		end
	end
	local sprite1 = nil
	if type(pszFileName) == "string" then
		sprite1 = TouchSprite:create(pszFileName)
		if sprite1 then
			sprite1:registerTouchUpHandler(func)
		end
	elseif pszFileName[2] then
		sprite1 = TouchSprite:createWithFrame(pszFileName[1],pszFileName[2])
		if sprite1 then
			sprite1:registerTouchUpHandler(func)
		end
	else
		sprite1 = TouchSprite:createWithFrame(pszFileName[1])
		if sprite1 then
			sprite1:registerTouchUpHandler(func)
		end
	end
	
	if sprite1 then
		sprite1:setTouchEnable(true)
		if parent then
			parent:addChild(sprite1)
		end
		sprite1:setPosition(pos)
		if action then
			local downActFunc = function(hander) 
				if hander then
					hander:runAction(cc.ScaleTo:create(0.15,1.15))
				end
				if downFunc then downFunc(sender) end
			end
			sprite1:registerTouchDownHandler(downActFunc)
		else
			if downFunc then
				sprite1:registerTouchDownHandler(downFunc)
			end
		end
	end
	
	return sprite1
end

function createScale9SpriteMenu(parent, pszFileName, size,pos, callback,file)
	if not parent then
		return
	end
	local sprite1 = Touch9Sprite:create(pszFileName,size)
	if sprite1 then
		if callback then
			sprite1:registerTouchUpHandler(callback)
		end
		if file then
			createSprite(sprite1,file,cc.p(0,size.height/2),cc.p(1.0,0.5))
			local c_sprite = createSprite(sprite1,file,cc.p(size.width,size.height/2),cc.p(0.0,0.5))
			c_sprite:setFlippedX(true)
		end
		parent:addChild(sprite1)
		sprite1:setPosition(pos)
	end
	return sprite1
end


function creatTabControlMenu(parent,tabs,select_index,zOrder)
    local selected_tag = select_index
	local menu = cc.Menu:create()
	local zOrder = zOrder or 0
	parent:addChild(menu,zOrder)
	menu:setPosition(0,0)

	local function selectedTag(value)
		selected_tag = value
	end

    for k, v in pairs(tabs) do
     --   local menu_item = cc.MenuImageItem:create(v.normal,v.select)
       -- v.menu_item = menu_item
        menu:addChild(v.menu_item,k)
    	local function callback(tag)
    		local ret = v.callback(k)
    		if not ret then
	    		if selected_tag and selected_tag ~= k then
	                tabs[selected_tag].menu_item:unselected()
	                if tabs[selected_tag].label then
	                	tabs[selected_tag].label:setColor(MColor.lable_black)
	                end
	    		end
	    		v.menu_item:selected()
	    		if v.label then
	                v.label:setColor(MColor.lable_yellow)
	            end

	            selected_tag = k 
	        end
            AudioEnginer.playTouchPointEffect()
    	end
    	v.menu_item:registerScriptTapHandler(callback)
    	v.selectedTag = selectedTag
        if k == select_index then
            v.menu_item:selected()
            if v.label then
                v.label:setColor(MColor.lable_yellow)
            end
        end
    end
    return menu
end

function createMultiLineLabel(parent, content, pos, anchor, fontSize, isOutLine, zorder, fontName, fontColor, specificWidth, lineHeight, isTopToBottom)
	isTopToBottom = isTopToBottom or true

	local labelTab = {}
	local strTab = {}
	local strLeft = content
	if not specificWidth then
		local flag = "\n"
		while string.find(strLeft, flag) do
			local index = string.find(strLeft, flag)
			strL = string.sub(strLeft, 1, index - 1)
			strR = string.sub(strLeft, index + 1)
			--log("strL = "..strL)
			--log("strR = "..strR)
			table.insert(strTab, strL) 
			strLeft = strR
		end
		table.insert(strTab, strLeft) 
	else
		local tempNode = cc.Node:create()
		local lebelTemp = createLabel(tempNode, strLeft, pos, anchor, fontSize)
		while lebelTemp:getContentSize().width > specificWidth do
			local index = 1
			for i=1,string.utf8len(strLeft) do
				local strTest = string.utf8sub(strLeft,1,i)
				--log("strTest = "..strTest)
				local labelTest = createLabel(tempNode, strTest, pos, anchor, fontSize)
				if labelTest:getContentSize().width > specificWidth then
					index = i-1
					break
				end
			end
			--log("index = "..index)
			strL = string.utf8sub(strLeft, 1, index)
			strR = string.utf8sub(strLeft, index + 1)
			--log("strL = "..strL)
			--log("strR = "..strR)
			table.insert(strTab, strL) 
			strLeft = strR
			lebelTemp = createLabel(tempNode, strLeft, pos, anchor, fontSize)
		end
		table.insert(strTab, strLeft) 
	end

	local posTemp = pos
	for k,v in pairs(strTab) do
		local label = createLabel(parent, v, posTemp, anchor, fontSize, isOutLine, zorder, fontName, fontColor)
		if isTopToBottom then
			posTemp = cc.p(posTemp.x, posTemp.y - lineHeight)
		else
			posTemp = cc.p(posTemp.x, posTemp.y + lineHeight)
		end
		table.insert(labelTab, label) 
	end

	return labelTab
end

function createLabel(parent, sContent,pos, anchor, fontSize, isOutLine, izorder, fontName, fontColor, tag, specificWidth, outLineColor, outLineWidth)
	if isOutLine or outLineColor then
		isOutLine = true
	end
	local fontSize = fontSize or 28
	local isOutLine = isOutLine or false
	if fontColor == nil then
		if isOutLine then
			fontColor = MColor.lable_yellow
		else
			fontColor = cc.c3b(255, 255, 255)
		end
	end
	local anchor = anchor or cc.p(0.5,0.5)
	--local pTTFRet = cc.Label:createWithSystemFont(sContent, fontName, fontSize)

	local pTTFRet = nil
	local contentType = type(sContent)
	if contentType ~= "string" and contentType ~= "number" then
		pTTFRet = cc.Label:createWithTTF("", g_font_path, fontSize)
	else
		pTTFRet = cc.Label:createWithTTF(sContent, g_font_path, fontSize)
	end

	if pTTFRet then 
		setNodeAttr(pTTFRet, pos, anchor, izorder, tag)
		pTTFRet:setColor(fontColor)
		
		if specificWidth then
			pTTFRet:setDimensions(specificWidth,0)
		end
		if parent then
			parent:addChild(pTTFRet)
		end		 
	end
	-- if labelNode and isOutLine then
	-- 	if Device_target == cc.PLATFORM_OS_ANDROID or Device_target == cc.PLATFORM_OS_WINDOWS then
	-- 		labelNode:enableShadow(cc.c4b(24, 17, 14,255),cc.size(1,1))
	-- 	else
	-- 		labelNode:enableShadow(cc.c4b(24, 17, 14,255),cc.size(2,2))
	-- 	end
	-- end
	return pTTFRet
end

function createBatchRootNode(parent,fontSize,pos)
	local lab_ttf = {}
    lab_ttf.fontFilePath = "fonts/msyh.ttf"
    lab_ttf.fontSize = fontSize
    local node = MirBatchDrawLabel:createWithTTF(lab_ttf)
	node:setPosition(pos or cc.p(0, 0))
	if parent then parent:addChild(node) end
	return node
end

function createBatchLabel(parent, sContent,pos, anchor, fontSize, isOutLine, izorder, fontName, fontColor, tag, specificWidth, outLineColor, outLineWidth)
	if parent then
		local labelNode = parent:createLabel(sContent or "",izorder or 0, pos or cc.p(0,0))
		if labelNode then
			if fontColor then
				labelNode:setColor(fontColor)
			end
			if anchor then
				labelNode:setAnchorPoint(anchor)
			end
		end
		return labelNode
	end
end



function createScale9Sprite(parent, pszFileName, pos,size, anchor,rect, fScale, zOrder, capinsets)
	local retSprite
	if rect then
		retSprite = cc.Scale9Sprite:create(pszFileName, rect)
	else
		retSprite = cc.Scale9Sprite:create(pszFileName)
	end
	if retSprite then
		setNodeAttr(retSprite, pos, anchor, zOrder,tag,fScale)
		if capinsets then
			retSprite:setCapInsets(capinsets)
		end
		if size then
			retSprite:setContentSize(size)
		end
		if parent then
			parent:addChild(retSprite)
		end
	end

	return retSprite
end

function createScale9Frame(parent, pszTiledFileName, pszFrameFileName, pos,size,frame_width,anchor)
	local rootNode =  cc.Node:create()
	if anchor then
		rootNode:setAnchorPoint(anchor)
	end
	rootNode:setPosition(pos)
	rootNode:setContentSize(size)
	if parent then
	    parent:addChild(rootNode)
	end

	local spTiledBg = cc.Sprite:create(pszTiledFileName, cc.rect(0, 0, size.width - frame_width * 2, size.height - frame_width * 2))
    spTiledBg:setAnchorPoint(cc.p(0, 0))
    spTiledBg:setPosition(cc.p(frame_width, frame_width))
    spTiledBg:getTexture():setTexParameters(gl.LINEAR, gl.LINEAR, gl.REPEAT, gl.REPEAT)
    rootNode:addChild(spTiledBg)

	local retSprite = cc.Scale9Sprite:create(pszFrameFileName)	
	if retSprite then
		retSprite:setAnchorPoint(cc.p(0, 0))
		retSprite:setPosition(cc.p(0, 0))
		retSprite:setContentSize(size)
		rootNode:addChild(retSprite)
	end

	return rootNode
end

-- 结算界面通用背景
-- plateHeight: 中间花纹的高度
-- @sample: CreateSettleFrame(self.m_bg, cc.p(self.m_bg:getContentSize().width/2, self.m_bg:getContentSize().height/2), 400, cc.p(0.5, 0.5));
function CreateSettleFrame(parent, pos, plateHeight, anchor)
    -- 最下层高度
    local DOWN_HEIGHT = 32;
    -- 最上层高度
    local TOP_HEIGHT = 172
    -- 总节点宽度
    local TOTAL_WIDTH = 960;
    -- 总节点高度
    local TOTAL_HEIGHT = 399;
    -- 中间层延伸遮盖高度
    local ADDITIONAL_HEIGHT = 20;
    -- 中间层截取Y
    local CENTER_Y = 223;
    local CENTER_HEIGHT = 25;
    -- 花纹层总宽度
    local PLATE_TOTAL_WIDTH = 480;
    -- 花纹层总高度
    local PLATE_TOTAL_HEIGHT = 529;

    local rootNode = cc.Node:create();
    if anchor then
		rootNode:setAnchorPoint(anchor)
	end
    rootNode:setPosition(pos);
    rootNode:setContentSize(cc.size(TOTAL_WIDTH, TOP_HEIGHT + plateHeight + DOWN_HEIGHT));
    if parent then
	    parent:addChild(rootNode)
	end

    -- 中部
    --------------- setTextureRect 屏幕左上角开始往右下截取 -------------------------
    local centerSpr = cc.Sprite:create("res/common/bg/bg74.png", cc.rect(0, CENTER_Y, TOTAL_WIDTH, CENTER_HEIGHT));
    centerSpr:setAnchorPoint(cc.p(0, 0));
    centerSpr:setScaleY((plateHeight+ADDITIONAL_HEIGHT*2)/CENTER_HEIGHT);
    centerSpr:setPosition(0, DOWN_HEIGHT-ADDITIONAL_HEIGHT);
    rootNode:addChild(centerSpr);

    -- 最上部
    local topSpr = cc.Sprite:create("res/common/bg/bg74.png", cc.rect(0, 0, TOTAL_WIDTH, TOP_HEIGHT))
    topSpr:setAnchorPoint(cc.p(0, 0))
    topSpr:setPosition(cc.p(0, DOWN_HEIGHT+plateHeight))
    rootNode:addChild(topSpr);

    -- 最下部
    local downSpr = cc.Sprite:create("res/common/bg/bg74.png", cc.rect(0, TOTAL_HEIGHT-DOWN_HEIGHT, TOTAL_WIDTH, DOWN_HEIGHT))
    downSpr:setAnchorPoint(cc.p(0, 0))
    downSpr:setPosition(cc.p(0, 0))
    rootNode:addChild(downSpr);

    -- 花纹层
    local leftPlateSpr = cc.Sprite:create("res/common/bg/bg74-1.png", cc.rect(0, (PLATE_TOTAL_HEIGHT-plateHeight)/2, PLATE_TOTAL_WIDTH, plateHeight));
    leftPlateSpr:setAnchorPoint(cc.p(0, 0));
    leftPlateSpr:setPosition(cc.p(0, DOWN_HEIGHT))
    rootNode:addChild(leftPlateSpr);

    local rightPlateSpr = cc.Sprite:create("res/common/bg/bg74-1.png", cc.rect(0, (PLATE_TOTAL_HEIGHT-plateHeight)/2, PLATE_TOTAL_WIDTH, plateHeight));
    rightPlateSpr:setAnchorPoint(cc.p(0, 0));
    rightPlateSpr:setPosition(cc.p(TOTAL_WIDTH-PLATE_TOTAL_WIDTH, DOWN_HEIGHT))
    rightPlateSpr:setFlippedX(true);
    rootNode:addChild(rightPlateSpr);
    

    return rootNode;
end

-- 列表标题[高度固定] kuniu\res\common\scalable\scale14.png 64*64
-- CreateListTitle(parentSpr, cc.p(0, 0), 300);
function CreateListTitle(parent, pos, width, height, anchor)
    local retSprite = cc.Scale9Sprite:create(cc.rect(20, 20, 24, 24), "res/common/scalable/scale14.png");
	if retSprite then
		if anchor then
			retSprite:setAnchorPoint(anchor)
		end

		retSprite:setPosition(pos);
		retSprite:setContentSize(cc.size(width, height));
	end

    if parent then
	    parent:addChild(retSprite)
	end

    return retSprite;
end

function createEditBox(parent,pszFileName,pos,size,color,font_size,placeholdstr)
	local box
    if pszFileName then
    	box = ccui.EditBox:create(size,cc.Scale9Sprite:create(pszFileName))
    else
    	box = ccui.EditBox:create(size,cc.Scale9Sprite:create())
    end
    if pos then box:setPosition(pos) end
    if color then box:setFontColor(color) end
   -- box:setInputMode(kEditBoxInputModeAny)
   	--box:setInputFlag(kEditBoxInputFlagInitialCapsWord)
    box:setFont(g_font_path, font_size or 20)
    if placeholdstr then
    	box:setPlaceholderFont(g_font_path, font_size or 20)
    	box:setPlaceHolder(placeholdstr)
    end
    if parent then
		parent:addChild(box)
	end
	return box
end

function createTips(parent,msgstr)
	local msgbg = createSprite(parent,"res/mainui/39.png",cc.p(g_scrSize.width/2,g_scrSize.height/2),cc.p(0.5,1.0))
	msgbg:setLocalZOrder(999)
	msgbg:setScale(0.1)
	--createSprite(msgbg,"res/mainui/41.png",cc.p(25,23),cc.p(0.5,0.5))
	local msg_label = createLabel(msgbg,msgstr,cc.p(203,23),cc.p(0.5,0.5),22)
		--msg_label:setColor(cc.c3b(255,10,5))
		--msg_label:setScale(0.1)
		--msg_label:setLocalZOrder(999)
		local actions = {}
		actions[#actions+1] = cc.ScaleTo:create(0.1,1.0)
		actions[#actions+1] = cc.MoveBy:create(0.3,cc.p(0,150))
		--actions[#actions+1] = cc.ScaleTo:create(0.05,1.0)
		actions[#actions+1] = cc.DelayTime:create(0.5)
		actions[#actions+1] = cc.FadeOut:create(0.5)
		actions[#actions+1] = cc.CallFunc:create(function()
								parent:removeChild(msgbg,true)
							end)
	msgbg:runAction(cc.Sequence:create(actions))
end


function drawUnderLine( neednode, fontColor )
	if neednode == nil then
		return nil
	end

	if not fontColor then
		fontColor = cc.c3b(255, 255, 255)
	end

	local s = neednode:getContentSize()
	local anchor = neednode:getAnchorPoint()
	local lineleft = neednode:getPositionX() - s.width * anchor.x + 2
	local liney = neednode:getPositionY()-s.height * anchor.y + 1

--	local line = cc.DrawNode:create()
--	line:setLineWidth(2)
--	line:drawLine( cc.p(lineleft, liney), cc.p(lineleft + s.width - 1, liney), cc.c4f(fontColor.r / 255, fontColor.g / 255, fontColor.b / 255, 1))	

	local line = cc.Sprite:create()
	line:setTextureRect(cc.rect(0,0,2,2))
	line:setAnchorPoint(cc.p(0,0.5))
	line:setPosition(cc.p(lineleft, liney))
	local scale = (neednode:getContentSize().width - 1)/line:getContentSize().width
	line:setScaleX(scale)
	line:setColor(fontColor)
	
	local parent = neednode:getParent()
	if parent then
		parent:addChild(line)
	end

	return line
end

function createLinkLabel(parent, sContent, pos, anchor, fontSize, isOutLine, fontName, fontColor, specificWidth, func, needLine)
	if not fontSize then
		fontSize = 28.0
	end
	if not fontName then
		fontName = g_font_path
	end

	local ttfConfig = {}
	ttfConfig.fontFilePath = fontName
	ttfConfig.fontSize = fontSize

	if not isOutLine then
		isOutLine = false
	end

	if not anchor then
		anchor = cc.p(0.5, 0.5)
	end

	if not fontColor then
		fontColor = cc.c3b(255, 255, 255)
	end
	local pTTFRet = createLabel(nil, sContent, pos, anchor, fontSize, isOutLine, nil, fontName, fontColor, nil, specificWidth)

	-- local line = nil
	-- if needLine then
	-- 	local s = pTTFRet:getContentSize()
	-- 	line = cc.Label:createWithTTF("_",g_font_path,18)
	-- 	line:setAnchorPoint(anchor)
	-- 	line:setPosition(cc.p(pos.x,pos.y-4))
	-- 	if fontSize >= 22 then
	-- 		line:setPosition(cc.p(pos.x,pos.y-10))
	-- 	end

	-- 	local scale = (s.width)/line:getContentSize().width
	-- 	line:setScaleX(scale)
	-- 	line:setColor(fontColor)
	-- end
	-- if parent then
	-- 	if needLine and line then
	-- 		parent:addChild(line)
	-- 	end
	-- end

	if parent then
		parent:addChild(pTTFRet)
	end
	
	local line = nil
	if needLine then
		line = drawUnderLine(pTTFRet, fontColor)
	end

	if func then
		local  listenner = cc.EventListenerTouchOneByOne:create()
	    listenner:setSwallowTouches(true)
	    listenner:registerScriptHandler(function(touch, event)
	    		parent = parent or pTTFRet:getParent()
				local pt = parent:convertTouchToNodeSpace(touch)
				if cc.rectContainsPoint(pTTFRet:getBoundingBox(),pt) then
					return true
				end	    	
				return false
			end,cc.Handler.EVENT_TOUCH_BEGAN)
	    listenner:registerScriptHandler(function(touch, event)
	    		parent = parent or pTTFRet:getParent()
				local pt = parent:convertTouchToNodeSpace(touch)
				if cc.rectContainsPoint(pTTFRet:getBoundingBox(),pt) then
						func(pTTFRet:getString(),touch:getLocation())
				end
			end,cc.Handler.EVENT_TOUCH_ENDED)
	    local eventDispatcher = pTTFRet:getEventDispatcher()
	    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, pTTFRet)
	end

	return pTTFRet,line
end



function getConfigItem(pszFileName,index)
	local items = require(pszFileName)
	if index then
		return items[index]
	end
	return items
end

local  config_op = {}
function resetConfigItems()
	config_op = {}
end
-- 至少两个参数， 如果传两个参数返回对应 key 的表
--三个参数 返回对应 key 和 value对应的表
--四个参数 返回对应 key 和 value对应的表的相应ret_key 键值
function getConfigItemByKey(pszFileName,key,value,ret_key)
	local cfg = "src/config/"..pszFileName
	if g_Channel_tab.language and g_Channel_tab.language == "hk" then
        cfg = "src/config/"..pszFileName
    end
	if not key then
		local tOriginal = require(cfg)
		package.loaded[cfg] = nil
		return  tOriginal
	end
	local Mmisc = require "src/young/util/misc"
	config_op[pszFileName] = config_op[pszFileName] or  Mmisc:readConfig(cfg, key)
	if config_op[pszFileName] then
		local ret = nil
		if value then
			if ret_key then
				ret = config_op[pszFileName][value] and config_op[pszFileName][value][ret_key]
			else
				ret = config_op[pszFileName][value]
			end
			if ret == nil and type(value) == "number" then
				value = tostring(value)
				if ret_key then
					ret = config_op[pszFileName][value] and config_op[pszFileName][value][ret_key]
				else
					ret = config_op[pszFileName][value]
				end
			end
			return ret
		else
			return config_op[pszFileName]
		end
	end
	--[[
	for k,v in pairs(items) do
		for t,h in pairs(v) do
			if t == key_v and value == h then
				if k_value then
					return v[k_value]
				else
					return v
				end
			end
		end
	end
	]]
	return nil
end

--同 getConfigItemByKey  ，只是 key value为多对应关系
function getConfigItemByKeys(pszFileName,keys,values,ret_key)
	local cfg = "src/config/"..pszFileName
	if g_Channel_tab.language and g_Channel_tab.language == "hk" then
        cfg = "src/config/"..pszFileName
    end
	local Mmisc = require "src/young/util/misc"
	config_op[pszFileName] = config_op[pszFileName] or  Mmisc:readConfig(cfg, keys)
	if config_op[pszFileName] then
		if values then
			local ret = config_op[pszFileName]
			for i=1,#values do
				if ret then
					ret = ret[values[i]]
				end
			end
			if ret_key and ret then
				ret = ret[ret_key]
			end
			return ret
		else
			return config_op[pszFileName]
		end
	end
	--[[
	for k,v in pairs(items) do
		for t,h in pairs(v) do
			if t == key_v and value == h then
				if k_value then
					return v[k_value]
				else
					return v
				end
			end
		end
	end
	]]
	return nil
end


function SwallowTouches(node)
	local  listenner = cc.EventListenerTouchOneByOne:create()
    listenner:setSwallowTouches(true)
    listenner:registerScriptHandler(function(touch, event)
       		return true
        end,cc.Handler.EVENT_TOUCH_BEGAN )
    local eventDispatcher = node:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner,node)
end

function MessageBox(text,btn,callback,outSideNotClose)
	local retSprite = cc.Sprite:create("res/common/5.png")
	local r_size  = retSprite:getContentSize()
	createLabel(retSprite,  game.getStrByKey("tip"), cc.p(r_size.width/2, r_size.height -12), cc.p(0.5,1.0), 22, true)

	local contentRichText = require("src/RichText").new(retSprite,  cc.p(r_size.width/2, r_size.height/2 + 30), cc.size(r_size.width-58, 100), cc.p(0.5, 0.5), 25, 20, MColor.lable_yellow)
	contentRichText:addText(text, MColor.lable_yellow)
	contentRichText:setAutoWidth()
	contentRichText:format()

	local func = function()
		local removeFunc = function()
		    if retSprite then
		        removeFromParent(retSprite)
		        retSprite = nil
		    end
		end
		if callback then
			callback()
		end
		if tolua.cast(retSprite,"cc.Sprite") then
			retSprite:runAction(cc.Sequence:create(cc.ScaleTo:create(0.0, 0), cc.CallFunc:create(removeFunc)))	
		end
	end
	local menuItem = createMenuItem(retSprite,"res/component/button/50.png",cc.p(210,45),func)
	createLabel(menuItem,btn or game.getStrByKey("sure") ,getCenterPos(menuItem),nil,21,true)
	getRunScene():addChild(retSprite,400)
	retSprite:setPosition(cc.p(display.cx, display.cy))
	retSprite:setScale(0.01)
    retSprite:runAction(cc.ScaleTo:create(0.1, 1))
    if not outSideNotClose then
        -- if false not add this 
        registerOutsideCloseFunc( retSprite , func ,true)
    end
    SwallowTouches(retSprite)
	return retSprite
end

function MessageBoxYesNo(title,text,yesCallback,noCallback,yesText,noText,color,btnImage, spanxTemp)
	local retSprite = cc.Sprite:create("res/common/5.png")
	local r_size  = retSprite:getContentSize()
	createLabel(retSprite, title or game.getStrByKey("tip"), cc.p(r_size.width/2, r_size.height -12), cc.p(0.5,1.0), 22, true)

    if not color then
        color = MColor.lable_yellow
    end
	local contentRichText = require("src/RichText").new(retSprite, cc.p(r_size.width/2, r_size.height/2 + 30), cc.size(r_size.width-100, 100), cc.p(0.5, 0.5), 25, 20, color)
	contentRichText:addText(text, color)
	contentRichText:setAutoWidth()
	contentRichText:format()

	local funcYes = function()
		if yesCallback then
			yesCallback()
		end
		if tolua.cast(retSprite,"cc.Sprite") then
			retSprite:runAction(cc.Sequence:create(cc.ScaleTo:create(0.0, 0), cc.RemoveSelf:create()))	
		end
	end

	local funcNo = function()
		AudioEnginer.playEffect("sounds/uiMusic/ui_back.mp3", false)
		if noCallback then
			noCallback()
		end
		if tolua.cast(retSprite,"cc.Sprite") then
			retSprite:runAction(cc.Sequence:create(cc.ScaleTo:create(0.0, 0), cc.RemoveSelf:create()))	
		end
	end
	local btn_img,spanx = btnImage or "res/component/button/50.png", spanxTemp or 0
	if noCallback == false then
		btn_img = "res/component/button/51.png"
		spanx = 30
	end
	local menuItem = createMenuItem(retSprite,btn_img,cc.p(315+spanx,45),funcYes)
	createLabel(menuItem,yesText or  game.getStrByKey("sure") ,getCenterPos(menuItem),nil,21,true)

	if G_TUTO_NODE then G_TUTO_NODE:setTouchNode(menuItem, TOUCH_CONFIRM_YES) end

	local menuItem2 = createMenuItem(retSprite,btn_img,cc.p(100-spanx,45),funcNo,nil,nil,true)
	createLabel(menuItem2,noText or  game.getStrByKey("cancel"),getCenterPos(menuItem2),nil,21,true)
	getRunScene():addChild(retSprite,400)
	retSprite:setPosition(cc.p(display.cx, display.cy))

	SwallowTouches(retSprite)
	--print("test ###########################")
	if G_TUTO_NODE then G_TUTO_NODE:setShowNode(retSprite, SHOW_CONFIRM) end
	retSprite:registerScriptHandler(function(event)
		if event == "enter" then
			G_TUTO_NODE:setShowNode(retSprite, SHOW_CONFIRM)
		elseif event == "exit" then

		end
	end)
	retSprite:setScale(0.01)
    retSprite:runAction(cc.ScaleTo:create(0.1, 1))
    return retSprite,menuItem,menuItem2
end

function MessageBoxYesNoEx(title,text,yesCallback,noCallback,yesText,noText,hasClose,countDownTime,theTime,theTimePos)
	local retSprite = cc.Sprite:create("res/common/5.png")
	local r_size  = retSprite:getContentSize()
	createLabel(retSprite, title or game.getStrByKey("tip"), cc.p(r_size.width/2, r_size.height -12), cc.p(0.5,1.0), 22, true)
	local contentRichText = require("src/RichText").new(retSprite, cc.p(r_size.width/2, r_size.height/2 + 95), cc.size(r_size.width-58, 100), cc.p(0.5, 1 ), 25, 20, MColor.white)
	contentRichText:addText(text, MColor.white)
	contentRichText:setAutoWidth()
	contentRichText:format()

	local removeFunc = function()
	    if retSprite then
	        removeFromParent(retSprite)
	        retSprite = nil
	    end
	end
	local funcYes = function()
		if yesCallback then
			yesCallback()
		end
		if tolua.cast(retSprite,"cc.Sprite") then
			retSprite:runAction(cc.Sequence:create(cc.ScaleTo:create(0.0, 0), cc.RemoveSelf:create()))	
		end
	end

	local funcNo = function()
		AudioEnginer.playEffect("sounds/uiMusic/ui_back.mp3", false)
		if noCallback then
			noCallback()
		end
		if tolua.cast(retSprite,"cc.Sprite") then
			retSprite:runAction(cc.Sequence:create(cc.ScaleTo:create(0.0, 0), cc.RemoveSelf:create()))	
		end
	end
	retSprite.funcNo = funcNo
	if hasClose and hasClose == true then
		local closeMenu = createMenuItem(retSprite,"res/component/button/x2.png",cc.p(126,65),removeFunc)		
		setNodeAttr(closeMenu, cc.p(r_size.width-25 , r_size.height-25), cc.p(0.5, 0.5))
		registerOutsideCloseFunc( retSprite , removeFunc )
	end

	local menuItem = createMenuItem(retSprite,"res/component/button/50.png",cc.p(315,45),funcYes)
	local menuSize = menuItem:getContentSize()
	local uiOkLabel = createLabel(menuItem, yesText or  game.getStrByKey("sure") , cc.p(menuSize.width/2, menuSize.height/2), cc.p(0.5, 0.5), 22,true)
	local menuItem1 = createMenuItem(retSprite,"res/component/button/50.png",cc.p(100,45),funcNo,nil,nil,true)
	local uiCancelLabel = createLabel(menuItem1, noText or  game.getStrByKey("cancel"), cc.p(menuSize.width/2, menuSize.height/2), cc.p(0.5, 0.5), 22,true)

	getRunScene():addChild(retSprite,400)
	retSprite:setPosition(cc.p(display.cx, display.cy))

	SwallowTouches(retSprite)
	
	retSprite:setScale(0.01)
    retSprite:runAction(cc.ScaleTo:create(0.1, 1))

    if countDownTime then
    	local countDownLabel = nil
    	theTime = theTime or 5
    	theTimePos = theTimePos or 2
    	if theTimePos > 2 or theTimePos <= 0 then
    		theTimePos = 2
    	end
    	if theTimePos == 1 then
    		countDownLabel = createLabel(menuItem, "("..theTime..")", cc.p(menuSize.width-40,17), cc.p(0, 0), 18, true, 5, nil, MColor.green)
    	elseif theTimePos == 2 then
    		countDownLabel = createLabel(menuItem1, "("..theTime..")", cc.p(menuSize.width-40,17), cc.p(0, 0), 18, true, 5, nil, MColor.green)
    	end
    	local function countDownFunc()
			theTime = theTime - 1
			if theTime <= 0 then
				if theTimePos == 1 then
					funcYes()
				elseif theTimePos == 2 then
					funcNo()
				end
			else
				countDownLabel:setString("("..theTime..")")
			end
		end
		startTimerAction(retSprite, 1, true, countDownFunc)
    end

    return retSprite, menuItem, menuItem1, uiOkLabel, uiCancelLabel
end

function MenuItemYesNoEx(yesCallback,noCallback,yesText,noText,countDownTime,theTime,theTimePos)
    -- only menuitem no bg or extra
    local node = cc.Node:create()
	local funcYes = function()
		if yesCallback then
			yesCallback()
		end
        node:runAction(cc.Sequence:create(cc.ScaleTo:create(0.0, 0), cc.RemoveSelf:create()))	
	end

	local funcNo = function()
		AudioEnginer.playEffect("sounds/uiMusic/ui_back.mp3", false)
		if noCallback then
			noCallback()
		end
        node:runAction(cc.Sequence:create(cc.ScaleTo:create(0.0, 0), cc.RemoveSelf:create()))	
	end
	
	local menuItem = createMenuItem(node,"res/component/button/50.png",cc.p(315,45),funcYes)
	local menuSize = menuItem:getContentSize()
	createLabel(menuItem, yesText or  game.getStrByKey("sure") , cc.p(menuSize.width/2, menuSize.height/2), cc.p(0.5, 0.5), 22,true)
	local menuItem1 = createMenuItem(node,"res/component/button/50.png",cc.p(100,45),funcNo,nil,nil,true)
	createLabel(menuItem1, noText or  game.getStrByKey("cancel"), cc.p(menuSize.width/2, menuSize.height/2), cc.p(0.5, 0.5), 22,true)

	SwallowTouches(node)

    if countDownTime then
    	local countDownLabel = nil
    	theTime = theTime or 5
    	theTimePos = theTimePos or 2
    	if theTimePos > 2 or theTimePos <= 0 then
    		theTimePos = 2
    	end
    	if theTimePos == 1 then
    		countDownLabel = createLabel(menuItem, "("..theTime..")", cc.p(menuSize.width-40,17), cc.p(0, 0), 18, true, 5, nil, MColor.green)
    	elseif theTimePos == 2 then
    		countDownLabel = createLabel(menuItem1, "("..theTime..")", cc.p(menuSize.width-40,17), cc.p(0, 0), 18, true, 5, nil, MColor.green)
    	end
    	local function countDownFunc()
			theTime = theTime - 1
			if theTime <= 0 then
				if theTimePos == 1 then
					funcYes()
				elseif theTimePos == 2 then
                    funcNo()
				end
			else
				countDownLabel:setString("("..theTime..")")
			end
		end
		startTimerAction(node, 1, true, countDownFunc)
    end

    return node,menuItem,menuItem1
end

function MessageBoxYesNoOnTop(title,text,yesCallback,noCallback,yesText,noText)
	local retSprite = cc.Sprite:create("res/common/5.png")
	local r_size  = retSprite:getContentSize()
	createLabel(retSprite, title or game.getStrByKey("tip"), cc.p(r_size.width/2, r_size.height -12), cc.p(0.5,1.0), 22, true)

	local contentRichText = require("src/RichText").new(retSprite, cc.p(r_size.width/2, r_size.height/2 + 30), cc.size(r_size.width-100, 100), cc.p(0.5, 0.5), 25, 20, MColor.white)
	contentRichText:addText(text, MColor.white)
	contentRichText:setAutoWidth()
	contentRichText:format()

	local funcYes = function()
		if yesCallback then
			yesCallback()
		end
		if tolua.cast(retSprite,"cc.Sprite") then
			retSprite:runAction(cc.Sequence:create(cc.ScaleTo:create(0.0, 0), cc.RemoveSelf:create()))	
		end
	end

	local funcNo = function()
		AudioEnginer.playEffect("sounds/uiMusic/ui_back.mp3", false)
		if noCallback then
			noCallback()
		end
		if tolua.cast(retSprite,"cc.Sprite") then
			retSprite:runAction(cc.Sequence:create(cc.ScaleTo:create(0.0, 0), cc.RemoveSelf:create()))	
		end
	end
	local btn_img,spanx = "res/component/button/50.png",0
	if noCallback == false then
		btn_img = "res/component/button/51.png"
		spanx = 30
	end
	local menuItem = createMenuItem(retSprite,btn_img,cc.p(315+spanx,45),funcYes)
	createLabel(menuItem,yesText or  game.getStrByKey("sure") ,getCenterPos(menuItem),nil,21,true)

	if G_TUTO_NODE then G_TUTO_NODE:setTouchNode(menuItem, TOUCH_CONFIRM_YES) end

	local menuItem = createMenuItem(retSprite,btn_img,cc.p(100-spanx,45),funcNo,nil,nil,true)
	createLabel(menuItem,noText or  game.getStrByKey("cancel"),getCenterPos(menuItem),nil,21,true)
	if retSprite then
		(G_MAINSCENE or Director:getRunningScene() ):addChild(retSprite, 400)
	end
	retSprite:setPosition(cc.p(display.cx, display.cy))

	SwallowTouches(retSprite)
	--print("test ###########################")
	if G_TUTO_NODE then G_TUTO_NODE:setShowNode(retSprite, SHOW_CONFIRM) end
	retSprite:registerScriptHandler(function(event)
		if event == "enter" then
			G_TUTO_NODE:setShowNode(retSprite, SHOW_CONFIRM)
		elseif event == "exit" then

		end
	end)
	retSprite:setScale(0.01)
    retSprite:runAction(cc.ScaleTo:create(0.1, 1))
    return retSprite
end

function MonsterNameColor( rolelevel, monsterlevel )
	-- body  cc.c3b()
	local diff = monsterlevel - rolelevel
	local colors = {
			[1] = cc.c3b(178, 178, 178),
			[2] = cc.c3b(255, 255, 255),
			[3] = cc.c3b(0, 255, 0),
			[4] = cc.c3b(255, 255, 0),
			[5] = cc.c3b(255, 0, 0)
			}
	if diff <= -10 then
		return colors[1]
	elseif diff < -5 then
		return colors[2]
	elseif diff < 5 then
		return colors[3]
	elseif diff < 10 then
		return colors[4]
	else
		return colors[5]
	end
end

function createRichText(parent, pos, size, anchor, isIgnoreContentAdaptWithSize, tag, zOrder)
	--log("createRichText")
	pos = pos or cc.p(0, 0)
	size = size or cc.size(100, 100)
	anchor = anchor or cc.p(0.5, 0.5)
	local retRichText = require("src/RichText").new(parent , pos , size ,anchor , 22 , 20 , MColor.white)
	retRichText:setAutoWidth()
	if zOrder then
		retRichText:setLocalZOrder(zOrder)
	end

	if tag then
		retRichText:setTag(tag)
	end

	return retRichText
end

function addRichTextItem(parent,str,defaultFontColor,fontName,fontSize,opacity,isIgnoreFlags,callback)
	if parent then
		parent:addText( str , defaultFontColor or MColor.white , false )
		if fontSize then
			parent.fontSize = fontSize
		end
		parent:format()
		return
	end

end
local full_page_list = {}
local full_page_num = 0
function createBgSprite(parent, tileName, tileNameEx, quick_Type, endFunc, noHide)
	local commonPath = "res/common/"
	local bg_node = cc.Node:create()
	bg_node:setContentSize(cc.size(960,640))
	bg_node:setPosition(cc.p((g_scrSize.width-960)/2,(g_scrSize.height-640)/2))
	if parent then
		parent:addChild(bg_node)
	end
	local bg = createSprite(nil, commonPath.."newbg/base_bg.png", cc.p(display.width/2-(g_scrSize.width-960)/2, display.height/2-(g_scrSize.height-640)/2), cc.p(0.5, 0.5))
	if not noHide then
		bg:registerScriptHandler(function(event)
			if event == "enter" then
				for k,v in pairs(full_page_list)do
					if tolua.cast(v,"cc.Node") then
						v:setVisible(false)
					end
				end
				full_page_num = full_page_num + 1
				SpriteMonster:setHideCenterRect(true)
				table.insert(full_page_list,bg_node)
			elseif event == "exit" then
				if full_page_num > 0 then
					full_page_num = full_page_num - 1
					table.remove(full_page_list,#full_page_list)
				end
				if full_page_num <= 0 then
					SpriteMonster:setHideCenterRect(false)
				else
					local r_node = full_page_list[#full_page_list]
					if tolua.cast(r_node,"cc.Node") then
						r_node:setVisible(true)
					end
				end
			end
		end)
	end
	bg_node:addChild(bg,-1)
	local closeFunc = function() 
		local ret = nil
		if endFunc then 
			ret = endFunc()
		end
		if not ret then
			local cb = function() 
				TextureCache:removeUnusedTextures()
			end
			removeFromParent(parent or bg_node,cb)	
		end
	end

	local close_item = createTouchItem(bg_node, "res/component/button/X.png", cc.p(923,575), closeFunc, nil)
	close_item:setLocalZOrder(500)
	local name
	local tileName = tileName or ""
	if tileName then
		name = createLabel(bg_node, tileName, cc.p(480,595),cc.p(0.5, 0.5), 25, true, nil, nil)
		if name then
			name:setTag(12580)
		end
	end
	SwallowTouches(bg)
	--registerOutsideCloseFunc( bg , closeFunc ,true)
	function bg_node:remove()
		closeFunc()
	end
	return bg_node, close_item, name
end

function stringToTable(str,symbol)
	local result = {}
	local strRet = {}
	local index = 2
	local count = 1
	if not symbol then
		symbol = "]"
	end
    while true do
        local new_index = string.find(string.sub(str,index), symbol)
        if new_index then
        	new_index = new_index+index-1
        	--cclog("new_index"..new_index)
        	if index + 1 <= new_index then
        		local strTemp = string.sub(str,index, new_index - 1)
        		--cclog(strTemp)
        		strRet[count]=strTemp
        	end
        	index = new_index + 3
        	count = count + 1
        else
        	--cclog("break")
        	if count == 1 and str and #str > 0 then
        		strRet[count] = str
        	end
            break
        end
    end

    for i=1,#strRet do
    	local begin_index = 1
    	local j=1
    	result[i]={}
    	while true do
    		local end_index = string.find(string.sub(strRet[i],begin_index),",")
    		if end_index then
    			end_index = end_index+begin_index-1
    			if begin_index+1 <= end_index then
    				local temp = string.sub(strRet[i],begin_index,end_index-1)
    				--cclog(temp)
    				result[i][j] = (temp)
    			end
    			begin_index = end_index + 1
    		else
    			if begin_index <= #strRet[i] then
    				local temp = string.sub(strRet[i],begin_index,#strRet[i])
    				--cclog(temp)
    				result[i][j] = (temp)
    				break
    			end
    		end
    		j = j + 1
    	end
    end

    return result
end

function secondParse(secs)
	local h = math.floor(secs/3600)
	secs = secs-h*3600
	local m = math.floor(secs/60)
	secs = secs-m*60
	local str = ""
	if h > 0 then
		str = ""..h..game.getStrByKey("hour")
	end
	local ret = str..m..game.getStrByKey("min")..secs..game.getStrByKey("sec")
	--cclog(ret)
	return ret
end

--删除对像
function delObj(_obj )
  if _obj then
    if _obj[ "getLayer" ] then
      xpcall( function() removeFromParent(_obj:getLayer()) end , function() _obj = nil end ) -- 清除自己
    else
      removeFromParent(_obj) -- 清除自己
    end
    _obj = nil
  end
end

--弹出框
function popupBox( params )
  local params = params or {}
  ----------------------------------------------------------
  local bgFrame = params.bg     									--弹出框背景图
  local isTitle = params.title or nil                               --title及背景信息
  local isClose = params.close or nil                               --是否有关闭按钮
  local isCreateScale9Sprite = params.createScale9Sprite or nil 	--是否使用9宫格缩放图片
  local actionOff = params.actionOff or { offX = 0 , offY = 0 }     --动画终点坐标偏移，只对类型5起作用
  local isMain = params.isMain or nil
  local isMask = params.isMask or false 							--是否有背景黑色遮罩

  local actionType = params.actionType or 5                         --动画类型    ( 1 从上到下  ，2 从右到左 ， 3 从下到上  ， 4从左到右   ， 5点击位置放大到中间 ,6 纵向放大 ，7 横向放大 8 中心到四周放大 )
  local beginFun = params.beginFun or nil                           --开始动画完成回调
  local endFun = params.overFun or nil                              --结束动画完成回调
  local noCloseAction = params.noCloseAction or false               --是否执行关闭动画
  local isBgClickQuit = params.isBgClickQuit or false               --点击背景退出

  local zorder = params.zorder or 300                               --添加层级
  local parent = params.parent or getRunScene()                     --添加到
  
  local isNoSwallow = params.isNoSwallow or false                   --是否不吞噬  默认吞噬

  local pageIcon = params.pageIcon or nil 							--页面标记图标
  local isNewAction =  true    										--是否使用新的动画
  if params.noNewAction then isNewAction = false end   				--不使用新的动画

  local isHalf = params.isHalf or false 							--是不是半屏界面

  local pos = params.pos or nil 									--写死坐标
  local anch = params.anch or nil 									--写死锚点

  if isNewAction then
  	parent = getRunScene()
  end

  local node , __bg,closeBtn = nil , nil , nil
  if isMain then
  	node = cc.Node:create()
  	--node:setPosition(cc.p(480,320))
  	pos = cc.p(0,0)
  	__bg ,closeBtn = createBgSprite(node, isTitle and isTitle.textPath , nil ,nil,isClose and isClose.callback)
  	function __bg:close()
  		__bg:remove()
  	end
	function __bg:getCloseBtn()
	  	return closeBtn
	end
	function __bg:setTitle( titlePath )
	  	local  titleSp = __bg:getChildByTag(12580)
	  	if titleSp then
	  		titleSp:setTexture( titlePath )
	  	end
	end

	
  	elseif type( bgFrame ) == "table" then
	  	local bgImgs = bgFrame.bg
	  	for i = 1  , #bgImgs do
	  		local cfg = nil
	  		if type( bgImgs[i] ) == "string" then 
	  			cfg = { path = bgImgs[i] , offX = 0 , offY = 0  }
	  		elseif type( bgImgs[i] ) == "table" then 
	  			cfg = { path = bgImgs[i].path , offX = bgImgs[i].offX or 0  , offY = bgImgs[i].offY or 0  , zorder = bgImgs[i].zorder or nil }
	  		end

	  		if not node then
	  			node = createSprite( node, cfg.path , cc.p( display.cx + cfg.offX , display.cy + cfg.offY ), cc.p( 0.5 , 0.5 ) )
	  		else
	  			createSprite( node, cfg.path , cc.p( node:getContentSize().width/2 + cfg.offX , node:getContentSize().height/2 + cfg.offY ), cc.p( 0.5 , 0.5 ) , cfg.zorder )
	  		end
	  	end
	  	bgFrame = bgFrame.flag 		--修改bgFrame值 为字条串 ， 方便后边一些判断

  	else

	  if isCreateScale9Sprite then
	  	node = createScale9Sprite( node, bgFrame ,(  pos or cc.p(  display.cx , display.cy ) ) , isCreateScale9Sprite.size , ( anch or cc.p( 0.5 , 0.5 ) ) )
	  else
  		if isMask then
		  node = cc.LayerColor:create( cc.c4b( 0 , 0 , 0 , 125 ) )
		  __bg = createSprite( node , bgFrame, cc.p( display.cx , display.cy ), cc.p( 0.5 , 0.5 ) )
		else
	  		node = createSprite( node, bgFrame, cc.p( display.cx , display.cy ), cc.p( 0.5 , 0.5 ) )
		end
	  end
  end

  local bgSize = node:getContentSize()

  if __bg then
  	bgSize = __bg:getContentSize()
  end

  if not isNewAction then
  	parent:addChild( node , zorder )
  end

  function node:remove()
    delObj( node )
  end



  --动画初始化
  local setInitFun =  {
      ["1"] = function() setNodeAttr( node, cc.p( display.cx , display.height ), cc.p( 0.5 , 0.5 ) , nil ,nil, 0.2 )  end ,
      ["2"] = function() setNodeAttr( node, cc.p( display.width , display.cy ), cc.p( 0.5 , 0.5 ) , nil ,nil, 0.2 )  end ,
      ["3"] = function() setNodeAttr( node, cc.p( display.cx , -bgSize.width/2 ), cc.p( 0.5 , 0.5 ) , nil ,nil, 0.2 )  end ,
      ["4"] = function() setNodeAttr( node, cc.p( 0 , display.cy ), cc.p( 0.5 , 0.5 ) , nil ,nil, 0.2 ) end ,
      ["5"] = function() setNodeAttr( node, cc.p( clickX , clickY ), cc.p( 0.5 , 0.5 ) , nil ,nil, 0.2 ) end ,
      ["6"] = function() setNodeAttr( node, cc.p( display.cx , display.height/2 ), cc.p( 0.5 , 0.5 ) , nil ,nil, nil ) node:setScaleY( 0 )  end ,
      ["7"] = function() setNodeAttr( node, cc.p( display.cx , display.height/2 ), cc.p( 0.5 , 0.5 ) , nil ,nil, nil ) node:setScaleX( 0 )  end ,
      ["8"] = function() setNodeAttr( node, cc.p( display.cx , display.height/2 ), cc.p( 0.5 , 0.5 ) , nil ,nil, nil ) node:setScale( 0 )  end ,
  }
  
  --动画执行数据
  --EaseOut 慢到快 EaseElasticOut 弹性 EaseBounceOut 强弹
  local actionAry =
  {
      ["1"] = cc.Sequence:create({ cc.EaseBackOut:create( cc.Spawn:create( { cc.MoveTo:create(0.3 , cc.p( display.cx , display.cy ) )  , cc.ScaleTo:create(0.3, 1) } ) ) , cc.CallFunc:create(function() if beginFun then beginFun() end end) }),
      ["2"] = cc.Sequence:create({ cc.EaseBackOut:create( cc.Spawn:create( { cc.MoveTo:create(0.3 , cc.p( display.cx , display.cy ) )  , cc.ScaleTo:create(0.3, 1) } ) ) , cc.CallFunc:create(function() if beginFun then beginFun() end end) }),
      ["3"] = cc.Sequence:create({ cc.EaseBackOut:create( cc.Spawn:create( { cc.MoveTo:create(0.3 , cc.p( display.cx , display.cy ) )  , cc.ScaleTo:create(0.3, 1) } ) ) , cc.CallFunc:create(function() if beginFun then beginFun() end end) }),
      ["4"] = cc.Sequence:create({ cc.EaseBackOut:create( cc.Spawn:create( { cc.MoveTo:create(0.3 , cc.p( display.cx , display.cy ) )  , cc.ScaleTo:create(0.3, 1) } ) ) , cc.CallFunc:create(function() if beginFun then beginFun() end end) }),
      ["5"] = cc.Sequence:create({ cc.EaseBackOut:create( cc.Spawn:create( { cc.ScaleTo:create(0.2, 1) , cc.Sequence:create({ cc.DelayTime:create(0.05) ,  cc.MoveTo:create(0.2, cc.p( display.cx + actionOff.offX , display.cy + actionOff.offY ) )  }) , } ) ) , cc.CallFunc:create(function() if beginFun then beginFun() end end) }),
      ["6"] = cc.Sequence:create( { cc.EaseBackOut:create( cc.ScaleTo:create( 0.3 , 1 ) ) , cc.DelayTime:create( 1.5 ) , cc.CallFunc:create( function() if beginFun then beginFun() end end ) } ) ,
      ["7"] = cc.Sequence:create( { cc.EaseBackOut:create( cc.ScaleTo:create( 0.3 , 1 ) ) , cc.DelayTime:create( 1.5 ) , cc.CallFunc:create( function() if beginFun then beginFun() end end ) } ) ,
      ["8"] = cc.Sequence:create( { cc.EaseBackOut:create( cc.ScaleTo:create( 0.3 , 1 ) ) , cc.CallFunc:create( function() if beginFun then beginFun() end end ) } ) ,
  }

  local oldClickX , oldClickY = clickX , clickY
  local closeFun = function( tag )
		if __bg then node:runAction( cc.FadeOut:create( 0.8 ) ) end

	  local function actionEndFun()
	  		if node and node.remove then node:remove()  end
	  		if endFun then endFun() end 
	  		--if isMain then TextureCache:removeUnusedTextures() end
	  end



      local closeActionAry =
      {
        ["1"] = cc.Sequence:create( { cc.EaseBackOut:create( cc.Spawn:create( { cc.MoveTo:create(0.3 , cc.p( display.cx , display.height + 100 ) )  , cc.ScaleTo:create(0.3, 0.3) } ) ) , cc.CallFunc:create( actionEndFun ) } ) ,
        ["2"] = cc.Sequence:create( { cc.EaseBackOut:create( cc.Spawn:create( { cc.MoveTo:create(0.3 , cc.p( display.width + bgSize.width/2 , display.cy ) )  , cc.ScaleTo:create(0.3, 0.3) } ) ) , cc.CallFunc:create( actionEndFun ) } ) ,
        ["3"] = cc.Sequence:create( { cc.EaseBackOut:create( cc.Spawn:create( { cc.MoveTo:create(0.3 , cc.p( display.cx , -bgSize.height/2 ) )  , cc.ScaleTo:create(0.3, 0.3) } ) ) , cc.CallFunc:create(actionEndFun) } ) ,
        ["4"] = cc.Sequence:create( { cc.EaseBackOut:create( cc.Spawn:create( { cc.MoveTo:create(0.3 , cc.p( -bgSize.width/2 , display.cy ) )  , cc.ScaleTo:create(0.3, 0.3) } ) ) , cc.CallFunc:create(actionEndFun ) } ) ,
        ["5"] = cc.Sequence:create( { cc.Spawn:create( { cc.ScaleTo:create(0.15, 0.1 ) , cc.MoveTo:create(0.15 , cc.p( oldClickX , oldClickY  ) ) , } ) , cc.CallFunc:create( actionEndFun )  }),
        ["6"] = cc.Sequence:create( cc.ScaleTo:create( 0.2 , 1 , 0 ) , cc.CallFunc:create( actionEndFun ) ) , 
        -- ["7"] = cc.Sequence:create( cc.ScaleTo:create( 0.2 , 0 , 1 ) , cc.CallFunc:create( function() node:remove() if endFun then endFun() end end ) ) , 
        ["7"] = cc.Sequence:create( { cc.EaseBackOut:create( cc.Spawn:create( { cc.MoveTo:create(0.3 , cc.p( display.cx , display.height + 100 ) )  , cc.ScaleTo:create(0.3, 0.3) } ) ) , cc.CallFunc:create(actionEndFun ) } ) ,
        ["8"] = cc.Sequence:create( { cc.Spawn:create( { cc.MoveTo:create(0.3 , cc.p( display.cx , display.cy ) )  , cc.ScaleTo:create(0.3, 0 ) } ) , cc.CallFunc:create( actionEndFun ) } ) ,
       }

       if isClose and isClose.callback then  isClose.callback() end
       

 	  	if isNewAction then
			removeFromParent( node , actionEndFun )
		else

	       if noCloseAction then
	          node:remove()
	          --if isMain then TextureCache:removeUnusedTextures() end
	       else
	          xpcall( function() if node then node:runAction( closeActionAry[ actionType .. "" ] ) end end , function() actionEndFun()  end )
	       end
			
	  	end

    end
  ----------------------------------------------------------


  

  if isNewAction then
  		parent:addChild(node,zorder or 200 )
  		--[[]
  		Manimation:transit(
		{
			ref = parent ,
			node = node,
			curve = "-",
			sp = cc.p( clickX ,clickY ),
			ep = pos,
			zOrder = zorder or 200 ,
			swallow = false,
		})
]]
  else
	  setInitFun[ actionType .. "" ]()
	  node:runAction( actionAry[ actionType.. "" ] )
  end





  --背景附加
  if params.bgAdd then
    for i = 1 , tablenums( params.bgAdd ) do
      local curData = params.bgAdd[i]
      createSprite( __bg and __bg or node , curData.res , curData.pos , curData.anch )
    end
  end





if not isMain then

	local titleSp = nil
	local function createTitle()
	    --对应图片偏移
	    local imageOff =
	      {
	          [ COMMONPATH .. "2.jpg" ] ={ offX = 90 , offY = -20  }  ,
	          [ COMMONPATH .. "4.png" ] ={ offX = 0 , offY = 0  ,}  ,
	          [ COMMONPATH .. "frame.png" ] ={ offX = 0 , offY = 0  ,}  ,
	          [ COMMONPATH .. "5.png" ] ={ offX = 0 , offY = 25  }  ,
	          [ "notice" ] ={ offX = 323 , offY = 0  }  ,
	      }
	    if type(isTitle) ~= "table" then isTitle = {} end
	    local titleConfig = { offX = ( isTitle.offX or 0 ) , offY = ( isTitle.offY or 0 ) ,  textPath = ( isTitle.textPath or nil ) , textOffX = ( isTitle.textOffX or 0 ) , textOffY = ( isTitle.textOffY or 0 )  }


	    if bgFrame  == COMMONPATH .. "4.png" or bgFrame  == COMMONPATH .. "frame.png" then
		    local titleConfig = { text = isTitle.text or nil , bg = ( isTitle.bg or COMMONPATH .. "1.png" ) , offX = ( isTitle.offX or 0 ) , offY = ( isTitle.offY or 0 ) , textPath = ( isTitle.textPath or nil ) , textOffX = ( isTitle.textOffX or 0 ) , textOffY = ( isTitle.textOffY or 0 )  }
			local function createTitle( bg , text , textOffX , textOffY )
				  local tempNode1 = cc.Node:create()
				  local tempSp = cc.Sprite:create( bg )
				  setNodeAttr( tempSp , cc.p( -54 , 0 ) , cc.p( 0 , 0 ) )
	  			  tempNode1:addChild( tempSp )
				  tempSp:setScaleX( ( bgSize.width- 10 ) /tempSp:getContentSize().width )

				  tempNode1:setContentSize( tempSp:getContentSize() )

				  if text then
				    local tempSpSize = tempSp:getContentSize()
				    	local textSp = nil
				    	if titleConfig.text then
				    		textSp = createLabel( tempNode1 , titleConfig.text.str , cc.p( tempSpSize.width/2 + 30 + textOffX , tempSpSize.height/2 + textOffY ), cc.p( 0.5 , 0.5 ) ,  titleConfig.text.size , nil , nil , nil , titleConfig.text.color , nil , nil )
				    	else
				    		textSp = cc.Sprite:create( text )
						    setNodeAttr( textSp, cc.p( tempSpSize.width/2 + textOffX , tempSpSize.height/2 + 30 + textOffY ), cc.p( 0.5 , 0.5 ) , nil ,nil, nil )
						    tempNode1:addChild( textSp )
				    	end
				  end
				  return tempNode1
			end
		    titleSp = createTitle( titleConfig.bg , ( titleConfig.text and titleConfig.text or titleConfig.textPath ), titleConfig.textOffX , titleConfig.textOffY  )
		    setNodeAttr( titleSp, cc.p( bgSize.width/2 + titleConfig.offX + ( imageOff[ bgFrame .. "" ] and imageOff[ bgFrame .. "" ].offX or 0 ) - 36 , 10 + bgSize.height - titleSp:getContentSize().height/2 + titleConfig.offY + ( imageOff[ bgFrame .. "" ] and imageOff[ bgFrame .. "" ].offY or 0  ) ), cc.p( 0.5 , 0.5 ) , nil ,nil, nil )
		    
		    if __bg then
		    	__bg:addChild( titleSp )
		    else
		    	node:addChild( titleSp )
		    end
	    else
		    titleSp = createSprite( node , titleConfig.textPath , cc.p( 0 , 0 ) , cc.p( 0 , 0 ) )
		    setNodeAttr( titleSp , cc.p( titleConfig.offX + ( imageOff[ bgFrame .. "" ] and imageOff[ bgFrame .. "" ].offX or 0  ) + titleSp:getContentSize().width/2 - 10 , 10 + bgSize.height - titleSp:getContentSize().height/2 + titleConfig.offY + ( imageOff[ bgFrame .. "" ] and imageOff[ bgFrame .. "" ].offY or 0  ) ), cc.p( 0.5 , 0.5 ) )
	    end

	end

  if isTitle then createTitle() end

  if isClose then

    --对应图片偏移
    local imageOff =
      {
          [ COMMONPATH .. "2.jpg" ] ={ offX = -40 , offY = -43  }  ,
          [ COMMONPATH .. "4.png" ] ={ offX = -20 , offY = -20  }  ,
          [ COMMONPATH .. "frame.png" ] ={ offX = -20 , offY = -20  }  ,
          [ COMMONPATH .. "5.png" ] ={ offX = -55 , offY = -40  }  ,
          [ "notice" ] ={ offX = -70 , offY = -70  }  ,
      }
    if type(isClose) ~= "table" then isClose = {} end
    local closeConfig = { scale = isClose.scale or 1 , path = ( isClose.path or "res/component/button/6.png" ) , x = ( isClose.x or nil ) , y = ( isClose.y or nil ) , callback = ( isClose.callback or function()end ) , offX = ( isClose.offX or 0 ) , offY = ( isClose.offY or 0 ) }

    local closeSize = cc.Sprite:create( closeConfig.path ):getContentSize()
    local addrX = ( closeConfig.x or ( bgSize.width - closeSize.width/2 ) ) + closeConfig.offX + ( bgFrame and ( imageOff[ bgFrame .. "" ] and imageOff[ bgFrame .. "" ].offX or 0  ) or 0 )
    local addrY = ( closeConfig.y or ( bgSize.height - closeSize.height/2 ) ) + closeConfig.offY + ( bgFrame and ( imageOff[ bgFrame .. "" ] and imageOff[ bgFrame .. "" ].offY or 0 ) or 0 )
    closeBtn = createMenuItem( __bg and __bg or node , closeConfig.path , cc.p( ( addrX + closeSize.width/2 ) , ( addrY + closeSize.height/2 ) ), function() closeFun() end)
    -- closeBtn = createTouchItem( __bg and __bg or node , closeConfig.path , cc.p( ( addrX + closeSize.width/2 ) , ( addrY + closeSize.height/2 ) ), function() closeFun() end , nil )
    closeBtn:setScale( closeConfig.scale )
    setNodeAttr( closeBtn, cc.p( ( addrX + closeSize.width/2 ) , ( addrY + closeSize.height/2 ) ) , cc.p( 0.5 , 0.5 ) , nil ,nil, nil )

  end


  local pageIconFlag = nil 
  local function createIcon()
	local pageConfig = { path = pageIcon.path , offX = pageIcon.offX or 0 , offY = pageIcon.offY or 0 }
	pageIconFlag = createSprite( node , pageConfig.path , cc.p(  50 + pageConfig.offX , 600 + pageConfig.offY  ) , cc.p( 0.5 , 0.5 ) )
  end
  -- if pageIcon then createIcon() end


  local function initTouch()
    local  listenner = cc.EventListenerTouchOneByOne:create()
    listenner:setSwallowTouches( true )
    listenner:registerScriptHandler(function(touch, event)   
    	if isBgClickQuit then closeFun() end 
    	local pt = node:getParent():convertTouchToNodeSpace(touch)
		if cc.rectContainsPoint(node:getBoundingBox(), pt) then 
    		return true
    	else
    		closeFun() 
    		AudioEnginer.playTouchPointEffect() 
    	end
    	return true
    	end, cc.Handler.EVENT_TOUCH_BEGAN )
    local eventDispatcher = node:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner,node)
  end

  if not isNoSwallow then initTouch() end





  function node:close()
    closeFun()
  end
  function node:getCloseBtn()
  	return closeBtn
  end


  function node:setTitle( titlePath ) 
  	if titleSp then
  		titleSp:setTexture( titlePath )
  	else
  		isTitle = { textPath = titlePath }
  		createTitle()	
  	end
  end
  function node:setIcon( iconPath ) 
  	if pageIconFlag then
  		pageIconFlag:setTexture( iconPath )
  	else
  		pageIcon = { path = iconPath }
  		createIcon()	
  	end
  end
  end
  --if isHalf then registerOutsideCloseFunc( node , function() node:close() end ) end
  --registerOutsideCloseFunc( node , function() node:close() end )
  return isMain and __bg or node
end

--道具物品
function iconCell( params )
  params = params or {}
  local iconID = params.iconID
  local parent = params.parent
  local tag = params.tag or -1
  local callback = params.callback or function()end

  local allData = params.allData or nil 
  local binding , streng , quality , upStar , time = nil , nil , nil , nil , nil 

  if allData then
	if allData.streng then
	  allData.streng = allData.streng and tonumber(allData.streng) or nil
	end
  	binding = allData.binding or nil   	--绑定(1绑定0不绑定)
  	streng  = allData.streng or nil  	--强化等级
  	quality = allData.quality or nil 	--品质等级
  	upStar  = allData.upStar or nil 	--升星等级
  	time 	= allData.time or nil 		--限时时间
  end

  local isTip = params.isTip or false         --是否点击弹出tip
  local isEffect = params.effect or false 		--是否有光效

  local isCustom = params.customIcon or nil 	--是否自定义icon

  local propOp = require( "src/config/propOp" )
  local parentSize = parent:getContentSize()


  if isCustom then
  	local idCfg = { 1000 , 4000 , 2010 , 333333 , 1200 } -- 1白色，2绿色，3蓝色，4紫色，5橙色  假ID生成样式差不多的图标
  	iconID = idCfg[ isCustom.colorLv ]
  	if isCustom.callback then
	  	isTip = false
	  	callback = isCustom.callback
  	end
  end

  local function tipFun()
      -- local MTips = require "src/layers/bag/propTips"
      -- MTips.new( { protoId = iconID , girdId = nil , num = nil , actions = {} , } )
  end

  local Mprop = require( "src/layers/bag/prop" )
  local grid = MPackStruct:buildGrid(
  {
  	protoId = iconID,
  	num = params.num,
  	-- attr = {
  	-- 	[MPackStruct.eAttrStrengthLevel] = ( streng ~= 0 and streng or nil ) ,
  	-- 	[MPackStruct.eAttrBind] = ( binding ~= 0 and binding or nil ) ,
  	-- 	[MPackStruct.eAttrExpiration] = ( time ~= 0 and time or nil ) ,
  	-- },
  })

  
  local iconBtn = Mprop.new({
						  	cb = ( isTip and "tips" or callback ),
						  	swallow = params.swallow ,
						  	grid = grid ,
						  	effect = isEffect,
						  	showBind = params.showBind ,
						  	isBind = params.isBind ,
						  	expiration = ( time ~= 0 and time or nil ) , 
						  	quality = quality,
						  	noFrame = params.noFrame,
							effect = params.effect,
						  })
  iconBtn:setTag( tag )
  parent:addChild( iconBtn )
  local iconBtnSize = iconBtn:getContentSize()

  if params.name then
    local name = ( type(params.name) == "table" and params.name or {} )
    local cfg = { name = propOp.name( iconID ) or "" , size = name.size or 20 , offX = name.offX or 0 , offY = name.offY or 0 , color = name.color or propOp.nameColor( iconID ) }
    if isCustom then
    	if not isCustom.name then
    		createLabel( iconBtn , cfg.name , cc.p( iconBtnSize.width/2 + cfg.offX , -23 + cfg.offY ) , cc.p( 0.5 , 0 ) , 20 , nil , nil , nil , cfg.color )
    	end
    else
    	createLabel( iconBtn , cfg.name , cc.p( iconBtnSize.width/2 + cfg.offX , -23 + cfg.offY ) , cc.p( 0.5 , 0 ) , 20 , nil , nil , nil , cfg.color )
   	end
  end

  if isCustom then 
		iconBtn:forceSetIcon( isCustom.icon ) 
    if isCustom.name then
		local tNameColor = {[0] = MColor.red, [1] = MColor.white, [2] = MColor.green, [3] = MColor.blue, [4] = MColor.purple, [5] = MColor.orange, }
		createLabel( iconBtn , isCustom.name , cc.p( iconBtnSize.width/2 , -20  ) , cc.p( 0.5 , 0 ) , 20 , nil , nil , nil , tNameColor[ isCustom.colorLv ]  )
	end
  end
  local numText = nil
  if params.num then
    local num = ( type(params.num) == "table" and params.num or {} )
    local cfg = { anch = num.anch or cc.p( 1 , 0 ) , value = num.value or 0 , size = num.size or 20 , offX = num.offX or 0 , offY = num.offY or 0 , color = num.color or MColor.white }
    
    if cfg.value < 10 then cfg.offX = -5 end
    numText = createLabel( iconBtn , ( tonumber( cfg.value ) >= 10000 and math.floor( tonumber( cfg.value ) /1000 )/10 .. game.getStrByKey( "ten_thousand" ) or cfg.value ) , cc.p( iconBtnSize.width + cfg.offX -3 , 0 + cfg.offY ) , cfg.anch , cfg.size , nil , 50 , nil , cfg.color )
    numText:enableOutline(cc.c4b(0, 0, 0, 255), 2)
    -- numText = createLabel( iconBtn , ( tonumber( cfg.value ) >= 10000 and math.floor( tonumber( cfg.value ) /1000 )/10 .. game.getStrByKey( "ten_thousand" ) or cfg.value ) , cc.p( iconBtnSize.width + cfg.offX - 3 , 0 + cfg.offY ) , cfg.anch , cfg.size , true , 50 , nil , cfg.color )
  end
  
  function iconBtn:setIsTip( _bool )
    isTip = _bool
    iconBtn:setCallback( isTip and "tips" or callback )
  end
  
  --设置个数
  function iconBtn:setNum( _num ) 
  	numText:setString( ( tonumber( _num) >= 10000 and math.floor( tonumber( _num ) /10000 ) .. game.getStrByKey( "ten_thousand" ) or _num )  )
  end

  return iconBtn
end

function stringsplit(str, delimiter)
    if (delimiter=='') then return false end
    local pos,arr = 0, {}
    -- for each divider found
    for st,sp in function() return string.find(str, delimiter, pos, true) end do
        table.insert(arr, string.sub(str, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(str, pos))
    return arr
end

function stringjoin(array, delimiter)
    if (delimiter=='') then return false end

    local str = '';
    for k , v in pairs(array) do
    	str = str .. v .. delimiter
    end

    str = string.sub(str , 0,string.len(str) - string.len(delimiter) )

    return str
end

function numToFatString(num)
	if num >= 10000 then
		if num >= 100000000 then
			num = math.floor(num / 1000000)
			if num % 100 ~= 0 then
				return string.format("%.1f", num/100)..game.getStrByKey("task_num_2")
			else
				return (num/100)..game.getStrByKey("task_num_2")
			end
		elseif num >= 10000000 then
			num = math.floor(num / 100000)
			if num % 100 ~= 0 then
				return string.format("%.1f", num/100)..game.getStrByKey("task_num_1")
			else
				return (num/100)..game.getStrByKey("task_num_1")
			end
		elseif num >= 100000 then
			num = math.floor(num / 1000)
			if num % 10 ~= 0 then
				return string.format("%.1f", num/10)..game.getStrByKey("task_num")
			else
				return (num/10)..game.getStrByKey("task_num")
			end
		else
			return tostring(math.floor(num/1000)/10)..game.getStrByKey("task_num")
		end
	else
		return tostring(num)
	end
end

--创建进度条
function createBar( parmas )
  parmas = parmas or {}

  local pos = parmas.pos or cc.p( 0 , 0 )
  local anchor = parmas.anchor  or cc.p( 0 , 0 )
  local zOrder = parmas.zOrder or 1
  local parent = parmas.parent or nil
  local percentageValue = parmas.percentage or 0     --当前进度

  local bg = parmas.bg      --背景图片，只需要给出图片路径
  local front = { path = parmas.front.path  , offX = parmas.front.offX or 0  , offY = parmas.front.offY or 0 } --前景图片需要table类型，给出偏移值

  local node =  cc.Node:create()
  
  local bg = createSprite( node , bg , cc.p( 0 , 0 ) , cc.p( 0 , 0 ) )
  local bgSize = bg:getContentSize()
  
  local frontSp = cc.ProgressTimer:create( cc.Sprite:create( front.path ) )

  frontSp:setType( cc.PROGRESS_TIMER_TYPE_BAR )
  frontSp:setBarChangeRate( cc.p( 1 , 0 ) )
  frontSp:setMidpoint( cc.p( 0 , 1 ) )
  frontSp:setPercentage( percentageValue )
  node:addChild( frontSp )

  setNodeAttr( frontSp , cc.p( front.offX , bgSize.height/2 + front.offY ) , cc.p( 0 , 0.5 ) )
  node:setContentSize( bgSize )

  function node:setPercentage( value )
      percentageValue = value
      frontSp:setPercentage( percentageValue )
  end
  function node:getPercentage()
    return percentageValue
  end
  if parent then
  	parent:addChild( node , zOrder )
  	setNodeAttr( node , pos , anchor )
  end

  return node
end

function addNetLoading(sendNetMsg, removeNetMsg, isReconnect, time, delaytime)
	log("addNetLoading wait for msg:"..tostring(removeNetMsg))
	userInfo.removeNetMsg = removeNetMsg
	require("src/base/NetLoading").new(isReconnect, time, delaytime)
end

--remove接口不能由各模块单独来调用，由接口层逻辑来控制
function removeNetLoading()
	--cclog("removeNetLoading")
	local loading = tolua.cast(Director:getRunningScene():getChildByTag(999999),"cc.Layer")
	if loading then
		local delay = 0.0
		if userInfo.loadingStartTime then
			delay = 0.5-(os.time()-userInfo.loadingStartTime)
			if delay < 0.0 or delay > 0.5 then
				delay = 0.0
			end
			loading:runAction(cc.Sequence:create(cc.DelayTime:create(delay),cc.RemoveSelf:create()))
		else
			Director:getRunningScene():removeChildByTag(999999)
		end
		userInfo.removeNetMsg = nil
	end
end

--点击node区域外会调用func
function registerOutsideCloseFunc(node, func, swallow, anycase, area)
	if (node == nil) or (func == nil) then
		return
	end

	local  listenner = cc.EventListenerTouchOneByOne:create()
	local flag = false
	if swallow then
		listenner:setSwallowTouches( true )
	end

	if not area then
		area = node:getBoundingBox()
	end

    listenner:registerScriptHandler(function(touch, event) 
								    	local pt = node:getParent():convertTouchToNodeSpace(touch)
										if cc.rectContainsPoint(area, pt) == false then
												flag = true
										end
    									return true 
    								end, cc.Handler.EVENT_TOUCH_BEGAN)
    listenner:registerScriptHandler(function(touch, event)
    	local start_pos = touch:getStartLocation()
		local now_pos = touch:getLocation()
		local span_pos = cc.p(now_pos.x-start_pos.x,now_pos.y-start_pos.y)
		if math.abs(span_pos.x) < 30 and math.abs(span_pos.y) < 30 then
			local pt = node:getParent():convertTouchToNodeSpace(touch)
			if flag and (cc.rectContainsPoint(area, pt) == false) or anycase then
				func()
				AudioEnginer.playTouchPointEffect()
			end
		end
	end, cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = node:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, node)
end


function getDirBrPos(direct,t_dir, length)
	local dir = t_dir or 6
	local PI = 3.1415926
	length = length or 5
	local ab_x ,ab_y = math.abs(direct.x),math.abs(direct.y)
	if (ab_x + ab_y) < length then return dir end
	local angel = math.atan2(ab_y,ab_x)
	
	if angel < PI/8 then
		if(direct.x < 0) then
			dir = 4
		else
			dir = 0
		end
	elseif  angel > PI*3/8 then
		if(direct.y > 0) then
			dir = 2
		else
			dir = 6
		end
	else 
		if(direct.x < 0 and direct.y < 0)then
			dir = 5
		elseif(direct.x < 0 and direct.y > 0)then
			dir = 3
		elseif(direct.x > 0 and direct.y > 0)then
			dir = 1
		elseif(direct.x > 0 and direct.y < 0)then
			dir = 7
		end
	end
	return dir
end

function startTimerAction(parent, delay, isLoop, callFunc)
	if parent == nil or delay == nil then
		return
	end
	local action = nil
	if isLoop == true then
		action = schedule(parent,callFunc,delay)
	else
		action = performWithDelay(parent,callFunc,delay)
	end
	return action
end

function startTimerActionEx(parent, delay, isLoop, callFunc)
	if parent == nil or delay == nil then
		return
	end

	local timeNode = require("src/TimeNode").new()
	timeNode:startTimer(delay, isLoop, callFunc)

	parent:addChild(timeNode)

	return timeNode
end

--时间转换  
function timeConvert( value , key, noHour )
	local hour,min,sec
	hour = math.floor(value / 3600)
	if hour >= 1 then
		min = math.floor((value - hour * 3600) / 60)
	else
		min = math.floor(value / 60)
	end
	sec = math.floor(value % 60 )
	
	hour = hour<10 and "0"..hour or hour 
	min = min<10 and "0"..min or min 
	sec = sec<10 and "0"..sec or sec
	
	if key == "hour" then
		return hour
	end
	if key == "min" then
		return min
	end
	if key == "sec" then
		return sec
	end
	
	if noHour then
		return min .. ":" .. sec
	else
		return hour .. ":" .. min .. ":" .. sec
	end
end

--序列化一个Table
function serialize(t)
	local mark={}
	local assign={}

	local function isArray(tab)
	if not tab then
		return false
	end

	local ret = true
	local idx = 1
	for f, v in pairs(tab) do
		if type(f) == "number" then
			if f ~= idx then
				ret = false
			end
		else
			ret = false
		end
		if not ret then break end
			idx = idx + 1
		end
		return ret
	end

	local function table2str(t, parent)
		mark[t] = parent
		local ret = {}

		if isArray(t) then
			table.foreach(t, function(i, v)
				local k = tostring(i)
				local dotkey = parent.."["..k.."]"
				local t = type(v)
				if t == "userdata" or t == "function" or t == "thread" or t == "proto" or t == "upval" then
					--ignore
				elseif t == "table" then
					if mark[v] then
						table.insert(assign, dotkey.."="..mark[v])
					else
						table.insert(ret, table2str(v, dotkey))
					end
				elseif t == "string" then
					table.insert(ret, string.format("%q", v))
				elseif t == "number" then
					if v == math.huge then
						table.insert(ret, "math.huge")
					elseif v == -math.huge then
						table.insert(ret, "-math.huge")
					else
						table.insert(ret,  tostring(v))
					end
				else
					table.insert(ret,  tostring(v))
				end
			end)
		else
			table.foreach(t, function(f, v)
				local k = type(f)=="number" and "["..f.."]" or f
				local dotkey = parent..(type(f)=="number" and k or "."..k)
				local t = type(v)
				if t == "userdata" or t == "function" or t == "thread" or t == "proto" or t == "upval" then
					--ignore
				elseif t == "table" then
					if mark[v] then
						table.insert(assign, dotkey.."="..mark[v])
					else
						table.insert(ret, string.format("%s=%s", k, table2str(v, dotkey)))
					end
				elseif t == "string" then
					table.insert(ret, string.format("%s=%q", k, v))
				elseif t == "number" then
					if v == math.huge then
						table.insert(ret, string.format("%s=%s", k, "math.huge"))
					elseif v == -math.huge then
						table.insert(ret, string.format("%s=%s", k, "-math.huge"))
					else
						table.insert(ret, string.format("%s=%s", k, tostring(v)))
					end
				else
					table.insert(ret, string.format("%s=%s", k, tostring(v)))
				end
			end)
		end

		return "{"..table.concat(ret,",").."}"
	end

	if type(t) == "table" then
		return string.format("%s%s",  table2str(t,"_"), table.concat(assign," "))
	else
		return tostring(t)
	end
end

--@note：反序列化一个Table
function unserialize(str)
	if str == nil or str == "nil" then
		return nil
	elseif type(str) ~= "string" then
		EMPTY_TABLE = {}
		return EMPTY_TABLE
	elseif #str == 0 then
		EMPTY_TABLE = {}
		return EMPTY_TABLE
	end

	local code, ret = pcall(loadstring(string.format("do local _=%s return _ end", str)))

	if code then
		return ret
	else
		EMPTY_TABLE = {}
		return EMPTY_TABLE
	end
end

--缩放到目标大小尺寸
function scaleToTarget(node, targetNode, additionalScaleX, additionalScaleY)
	local additionalScaleX = additionalScaleX or 1
	local additionalScaleY = additionalScaleY or 1

	local size = node:getContentSize()
	local targetSize = targetNode:getContentSize()
	local targetScale = targetNode:getScale()
	--dump(targetSize)
	--dump(targetScale)
	node:setScale(targetSize.width / size.width * additionalScaleX, 
		targetSize.height / size.height * additionalScaleY)
	--print("scale x = "..targetSize.width / size.width * additionalScaleX)
	--print("scale y = "..targetSize.height / size.height * additionalScaleY)
end

--缩放到目标大小尺寸
function scaleToSize(node, targetSize, additionalScaleX, additionalScaleY)
	local additionalScaleX = additionalScaleX or 1
	local additionalScaleY = additionalScaleY or 1

	local size = node:getContentSize()

	node:setScale(targetSize.width / size.width * additionalScaleX, 
		targetSize.height / size.height * additionalScaleY)
end

--保存本地记录(角色互斥)
function setLocalRecord(key, value)
	local MRoleStruct = require("src/layers/role/RoleStruct")
	local staticId = userInfo.currRoleStaticId
	--print(staticId.."-"..key.." set "..tostring(value))
	--dump(staticId)
	if staticId and key then
		cc.UserDefault:getInstance():setBoolForKey(staticId.."-"..key, value)
		cc.UserDefault:getInstance():flush()
	end
end

--读取本地记录
function getLocalRecord(key, role_id)
	local staticId = role_id or userInfo.currRoleStaticId
	--dump(staticId)
	if staticId and key then
		return cc.UserDefault:getInstance():getBoolForKey(staticId.."-"..key)
	end
end

--保存本地记录
function setLocalRecordByKey(c_type, key, value)
	-- 1 int 2 string 3 bool
	if key and type(key) == "string" and (value~=nil)  then
		if c_type == 1 then
			if type(value) == "number" then
				cc.UserDefault:getInstance():setIntegerForKey(key,value)
				cc.UserDefault:getInstance():flush()
			end
		elseif c_type == 2 then
			if type(value) == "string" then
				cc.UserDefault:getInstance():setStringForKey(key,value)
				cc.UserDefault:getInstance():flush()
			end
		elseif c_type == 3 then
			if type(value) == "boolean" then
				cc.UserDefault:getInstance():setBoolForKey(key,value)
				cc.UserDefault:getInstance():flush()
			end
		end
	end
end

--读取本地记录
function getLocalRecordByKey(c_type,key,default_value)
	-- 1 int 2 string 3 bool
	if key and (type(key) == "string") then
		if c_type == 1 then
			return cc.UserDefault:getInstance():getIntegerForKey(key,default_value or 0)
		elseif c_type == 2 then
			return cc.UserDefault:getInstance():getStringForKey(key,default_value or "")
		elseif c_type == 3 then
			return cc.UserDefault:getInstance():getBoolForKey(key,default_value or false)
		end
	end
end

function __removeAllLayers(withdelay,handerFunc)
	if G_MAINSCENE then
		local removeChild = function()
			if G_MAINSCENE and G_MAINSCENE.base_node then
				local coLayer = G_MAINSCENE and G_MAINSCENE:getChildByTag(51284)
				if coLayer then
					G_MAINSCENE:removeChildByTag(51284)
				end
				G_MAINSCENE.base_node:removeAllChildren()
				TextureCache:removeUnusedTextures()
			end
		end
		if withdelay then
			G_MAINSCENE._removeFunc = handerFunc or true
			performWithDelay(G_MAINSCENE,function() 
					if G_MAINSCENE then
						G_MAINSCENE._removeFunc = nil 
					end
				end ,2)
		else
			removeChild()
		end
	end
end

function earthQuake(delayTime,continue)
	--G_MAINSCENE.map_layer
	delayTime = delayTime or 0.1
	continue = continue or 0.5
	if G_MAINSCENE.map_layer then
		local theShake = startTimerAction(G_MAINSCENE.map_layer, delayTime, true, function()
				if G_MAINSCENE and G_MAINSCENE.map_layer then
					G_MAINSCENE.map_layer:runAction(cc.Sequence:create(cc.MoveBy:create(0.025, cc.p(2,-8)), cc.MoveBy:create(0.05, cc.p(-4,16)), cc.MoveBy:create(0.025, cc.p(2,-8))))
					--G_MAINSCENE.map_layer:runAction(cc.Sequence:create(cc.MoveBy:create(0.025, cc.p(-5,0)), cc.MoveBy:create(0.05, cc.p(10,0)), cc.MoveBy:create(0.025, cc.p(-5,0))))
				end
			end)

		startTimerAction(G_MAINSCENE.map_layer, delayTime+continue, true, function() 
			if theShake and G_MAINSCENE then
				G_MAINSCENE.map_layer:stopAction(theShake)
				theShake = nil
			end
		end)
	end
end

function cutRichText(str)                --专业去掉^%c()……^
	if str then
		if string.find(str,'^') then
			local bag = {}
			local bell = {}
			local j = 0
			for i=1,#str do
				if string.sub(str,i,i) == '^' then
					j = j + 1
					bag[j] = i
				end
			end
			if bag and j > 0 and j % 2 == 0 then
				bell[1] = string.sub(str,1,bag[1]-1)
				for k = 1,#bag ,1 do
					if bag[k] and bag[k+1] then
						bell[k+1] = string.sub(str,bag[k]+1,bag[k+1]-1)
						if string.find(bell[k+1],")") then
							bell[k+1] = string.sub(bell[k+1],string.find(bell[k+1],")")+1,-1)
						end
					end
				end
			
				bell[#bell+1] = string.sub(str,bag[#bag]+1,-1)
				for m = 2,#bell do
					bell[1] = bell[1]..bell[m]
				end
				return bell[1]
			else
				return str
			end
		else
			return str
		end
	end
end

function createPropIcon(parent, id, isWidthTipCallBack, isWithEffect, callback, isSwallow)
	local Mprop = require("src/layers/bag/prop")
	local param = {}
	param.protoId = id
	param.cb = "tips"
	param.effect = true

	if isWidthTipCallBack == false then
		param.cb = nil
	end

	if callback then
		param.cb = callback
	end

	if isWithEffect == false then
		param.effect = false
	end

	if isSwallow == false then
		param.isSwallow = isSwallow
	end

	local iconNode = Mprop.new(param)

	if parent then
		parent:addChild(iconNode)
	end

	return iconNode
end

function isBattleArea(mapId)
	local itemdate = getConfigItemByKey("AreaFlag", "mapID", mapId)
	if itemdate then
		return true
	end

	return false
end

function getBattleAreaInfo(mapId)
	local itemDate = getConfigItemByKey("AreaFlag", "mapID", mapId)
	local defaultPos = nil
	if itemDate then
		if itemDate.bannerPos then
			local strPos = itemDate.bannerPos
			local flgPos = string.find(strPos, ",")
			local posX = string.sub(strPos, 1, flgPos - 1)
			local posY = string.sub(strPos, flgPos + 1)
			defaultPos = cc.p(tonumber(posX), tonumber(posY))
		end	
		return itemDate, defaultPos
	end

	return nil
end

function getCenterPos(sprite, addX, addY)
	local size = sprite:getContentSize()
	local x ,y = size.width/2,size.height/2

	if addX then
		x = x + addX
	end

	if addY then
		y = y + addY
	end
	return cc.p(x, y)
end

function createAttNode(record, fontSize, fontColor)
	if record == nil then
		return nil
	end

	local attNodes = {}

	local formatStr2 = function(str1, str2)
		return str1.." "..str2
	end

	local formatStr3 = function(str1, str2, str3)
		return str1.." "..str2.."-"..str3
	end

	if record.q_max_hp then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0.5, 0,5), false)
		local str = formatStr2(game.getStrByKey("prop_hp"), record.q_max_hp)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_max_mp then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0.5, 0,5), false)
		local str = formatStr2(game.getStrByKey("prop_mp"), record.q_max_mp)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_attack_min and record.q_attack_max then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0.5, 0,5), false)
		local str = formatStr3(game.getStrByKey("prop_attack"), record.q_attack_min, record.q_attack_max)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_magic_attack_min and record.q_magic_attack_max then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0.5, 0,5), false)
		local str = formatStr3(game.getStrByKey("prop_magicAttack"), record.q_magic_attack_min, record.q_magic_attack_max)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_sc_attack_min and record.q_sc_attack_max then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0.5, 0,5), false)
		local str = formatStr3(game.getStrByKey("prop_scAttack"), record.q_sc_attack_min, record.q_sc_attack_max)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_defence_min and record.q_defence_max then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0.5, 0,5), false)
		local str = formatStr3(game.getStrByKey("prop_defence"), record.q_defence_min, record.q_defence_max)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_magic_defence_min and record.q_magic_defence_max then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0.5, 0,5), false)
		local str = formatStr3(game.getStrByKey("prop_magicDefence"), record.q_magic_defence_min, record.q_magic_defence_max)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_att_dodge then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0.5, 0,5), false)
		local str = formatStr2(game.getStrByKey("prop_attackDodge"), record.q_att_dodge)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_mac_dodge then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0.5, 0,5), false)
		local str = formatStr2(game.getStrByKey("prop_magicDodge"), record.q_mac_dodge)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_crit then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0.5, 0,5), false)
		local str = formatStr2(game.getStrByKey("prop_cirt"), record.q_crit)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_hit then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0.5, 0,5), false)
		local str = formatStr2(game.getStrByKey("prop_hit"), record.q_hit)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_dodge then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0.5, 0,5), false)
		local str = formatStr2(game.getStrByKey("prop_dodge"), record.q_dodge)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_attack_speed then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0.5, 0,5), false)
		local str = formatStr2(game.getStrByKey("prop_attackSpeed"), record.q_attack_speed)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_luck then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0.5, 0,5), false)
		local str = formatStr2(game.getStrByKey("prop_luck"), record.q_luck)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_addSpeed then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0.5, 0,5), false)
		local str = formatStr2(game.getStrByKey("prop_speed"), record.q_addSpeed)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_subAt then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0.5, 0,5), false)
		local str = formatStr2(game.getStrByKey("prop_subAt"), record.q_subAt)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_subMt then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0.5, 0,5), false)
		local str = formatStr2(game.getStrByKey("prop_subMt"), record.q_subMt)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_subDt then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0.5, 0,5), false)
		local str = formatStr2(game.getStrByKey("prop_subDt"), record.q_subDt)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_addAt then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0.5, 0,5), false)
		local str = formatStr2(game.getStrByKey("prop_addAt"), record.q_addAt)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_addMt then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0.5, 0,5), false)
		local str = formatStr2(game.getStrByKey("prop_addMt"), record.q_addMt)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	if record.q_addDt then
		richText = createRichText(nil, cc.p(0, 0), cc.size(320, 22), cc.p(0.5, 0,5), false)
		local str = formatStr2(game.getStrByKey("prop_addDt"), record.q_addDt)

		addRichTextItem(richText,str,fontColor,nil,fontSize,nil)
		table.insert(attNodes, richText)
	end

	local reverseTab = function(tab)
		local retTab = {}

		for i=#tab,1,-1 do
			retTab[#tab-i+1] = tab[i]
		end

		return retTab
	end

	attNodes = reverseTab(attNodes)

	log("#attNodes="..#attNodes)
	local attNode = Mnode.combineNode({
		nodes = attNodes,
		ori = "|",
		margins = 0,
		align = "c"
	})

	return attNode
end

function createMaskingLayer(time, isWithoutAction)
	local layer =  cc.LayerColor:create(cc.c4b(255, 255, 255, 0))
	if isWithoutAction ~= true then
		layer:runAction(cc.Sequence:create(cc.FadeIn:create(time/2), cc.FadeOut:create(time/2)))
	end
	startTimerAction(layer, time, false, function() removeFromParent(layer) end)

	SwallowTouches(layer)

	return layer
end

function createSwallowTouchesLayer(time)
	local layer = cc.Layer:create()
	SwallowTouches(layer)
	
	startTimerAction(layer, time, false, function() removeFromParent(layer) end)

	return layer
end

function createMonsterEffect(monster, effect_file, frame_count, time, loop)
	log("[createMonsterEffect] called start. file = %s, count = %d, time = %d, loop = %d.", effect_file, frame_count, time, loop)

	if monster == nil then
		return
	end
	if effect_file == nil then
		return
	end


	local monster_effect = Effects:create(false)
	monster_effect:playActionData(effect_file, frame_count, time, loop)
	if monster:getChildByTag(2244) then
		monster:removeChildByTag(2244)
	end

	monster:addChild(monster_effect, 100, 2244)
	local removeFunc = function()
		if monster and monster:getChildByTag(2244) then
			monster:removeChildByTag(2244)
		end
		monster_effect = nil
	end

	local duration = time * loop
	performWithDelay(monster, removeFunc, duration)

	return monster_effect
end

function checkNode(node)
	return tolua.cast(node, "cc.Node")
end

function addLoadingNode(times)
	local load_node = cc.Node:create()
	Director:getRunningScene():addChild(load_node,10000)
	local closeFunc = function()
		removeFromParent(load_node)
		load_node = nil
	end
	performWithDelay(load_node,closeFunc,times)

	local  listenner = cc.EventListenerTouchOneByOne:create()
    listenner:setSwallowTouches(true)
    listenner:registerScriptHandler(function(touch, event)
     	return true
        end,cc.Handler.EVENT_TOUCH_BEGAN )
    local eventDispatcher = load_node:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner,load_node)
end

--[[
RM_ALPHA == 0
RM_ADD1
RM_ADD2
RM_ALPHAADD
RM_MODULATE
]]
function addEffectWithMode(effect_node,mode_id)
	--effect_node:setRenderMode(mode_id)

	if mode_id == 1 then
		effect_node:setBlendFunc({src=gl.ONE,dst=gl.ONE_MINUS_SRC_COLOR})
	elseif mode_id == 2 then
		effect_node:setBlendFunc({src=gl.ONE,dst=gl.ONE})
	elseif mode_id == 3 then
		effect_node:setBlendFunc({src=gl.SRC_ALPHA,dst=gl.ONE})
	elseif mode_id == 0 then
		effect_node:setBlendFunc({src=gl.SRC_ALPHA,dst=gl.ONE_MINUS_SRC_ALPHA})
	elseif mode_id == 4 then
		effect_node:setBlendFunc({src=gl.ZERO,dst=gl.SRC_COLOR})
	end
end

function callStaticMethod(className,methodName,args,sig)
	if Device_target == cc.PLATFORM_OS_ANDROID then
        local luaj = require "cocos/cocos2d/luaj"
        local ok, ret = luaj.callStaticMethod(className, methodName, args, sig)
        return ok, ret
    elseif Device_target==cc.PLATFORM_OS_IPHONE or Device_target==cc.PLATFORM_OS_IPAD then
        local luaoc = require "cocos/cocos2d/luaoc"
        local ok,ret  = luaoc.callStaticMethod(className,methodName,args)
        return ok, ret
    end
end

-- 保留小数点位数
function GetPreciseDecimal(nNum, n)
    if type(nNum) ~= "number" then
        return nNum;
    end

    n = n or 0;
    n = math.floor(n);
    if n < 0 then
        n = 0;
    end

    local nDecimal = 10 ^ n;
    local nTemp = math.floor(nNum * nDecimal);
    local nRet = nTemp / nDecimal;
    return nRet;
end

-- input value range [0-99]
function valueDigitToChinese(value)
	local text = ""

	local getUnitText = function(index)
		local key = "num_" .. tostring(index)
		return game.getStrByKey(key)
	end

	if value < 0 then
		return text
	elseif value > 99 then
		value = 99
	end

	value = math.floor(value)

	if value <= 10 then
		text = getUnitText(value)
	else
		local nDT = math.floor(value / 10)
		local nDU = value % 10

		if nDT == 1 then
			text = getUnitText(10)
		else
			text = getUnitText(nDT) .. getUnitText(10)
		end

		if nDU > 0 then
			text = text .. getUnitText(nDU)
		end
	end

	return text
end


function removeFromParent(node, callback)
	local ExitConfig = node and node.OnExitTransition
	if ExitConfig then
		ExitConfig.cb = callback
		local Manimation = require "src/young/animation"
		Manimation:transit(ExitConfig)
	else
        if node then
		    local node_ex = tolua.cast(node,"cc.Node")
		    if node_ex then
			    --print(string.format(debug.traceback()))
			    node_ex:removeFromParent()
			    node_ex = nil
		    end
        end
		if callback then callback() end
	end
end

local liuAudioPlay1 = {}
function liuAudioPlay(filename, isLoop)
	if filename then
        table.insert(liuAudioPlay1,{filename,isLoop})
        local timee = (#liuAudioPlay1 - 1)*10
        if G_MAINSCENE then
        	G_MAINSCENE:runAction(cc.Sequence:create(cc.DelayTime:create(timee) ,cc.CallFunc:create(function()
		            AudioEnginer.playLiuEffect(liuAudioPlay1[1][1],liuAudioPlay1[1][2])
		            table.remove(liuAudioPlay1,1)
        	end)
        	))
        end

    end
end

function formatDateStr(time)
    local tmpStr = "";
    local tmpTime = os.date("*t", time);
    if tmpTime ~= nil then
        tmpStr = tmpTime.year .. ".";
        if tmpTime.month > 9 then
            tmpStr = tmpStr .. tmpTime.month .. ".";
        else
            tmpStr = tmpStr .. "0" .. tmpTime.month .. ".";
        end

        if tmpTime.day > 9 then
            tmpStr = tmpStr .. tmpTime.day .. "";
        else
            tmpStr = tmpStr .. "0" .. tmpTime.day .. "";
        end
    end

    return tmpStr;
end

function formatDateTimeStr(time)
    local tmpStr = "";
    local tmpTime = os.date("*t", time);
    if tmpTime ~= nil then
        tmpStr = tmpTime.year .. ".";
        if tmpTime.month > 9 then
            tmpStr = tmpStr .. tmpTime.month .. ".";
        else
            tmpStr = tmpStr .. "0" .. tmpTime.month .. ".";
        end

        if tmpTime.day > 9 then
            tmpStr = tmpStr .. tmpTime.day .. " ";
        else
            tmpStr = tmpStr .. "0" .. tmpTime.day .. " ";
        end

        if tmpTime.hour > 9 then
            tmpStr = tmpStr .. tmpTime.hour .. ":";
        else
            tmpStr = tmpStr .. "0" .. tmpTime.hour .. ":";
        end

        if tmpTime.min > 9 then
            tmpStr = tmpStr .. tmpTime.min .. ":";
        else
            tmpStr = tmpStr .. "0" .. tmpTime.min .. ":";
        end

        if tmpTime.sec > 9 then
            tmpStr = tmpStr .. tmpTime.sec;
        else
            tmpStr = tmpStr .. "0" .. tmpTime.sec;
        end
    end

    return tmpStr;
end


function createLoadingBar(isNeedBg,params)
	if params and params.parent and params.res then
		local size = params.size or cc.size(0,0)
		local pos = params.pos or cc.p(0,0)
		local percentage = params.percentage or 0
		local parent = params.parent or nil
		local anchor = params.anchor or cc.p(0,0.5)
		local dir = params.dir and ccui.LoadingBarDirection.LEFT or ccui.LoadingBarDirection.RIGHT

		local progress = ccui.LoadingBar:create()
		progress:setScale9Enabled(true)
		progress:loadTexture(params.res)
		progress:setContentSize(size)
		progress:setPosition(pos)
		if anchor then
			progress:setAnchorPoint(anchor)
		end

		progress:setDirection(dir)
		progress:setPercent(percentage)

		if isNeedBg then
			createScale9Sprite(progress,"res/component/progress/barBg.png",cc.p(-2,-3),cc.size(size.width+4,size.height+5),cc.p(0,0),nil,nil,-1,nil)
		end

		params.parent:addChild(progress)
		return progress
	end
end

function isChildOf( uiParent, uiChild )
	-- body
	print("isChildOf", uiParent == uiChild)
	if not IsNodeValid(uiParent) or not IsNodeValid(uiChild) then
		return false
	end
	if uiParent == uiChild then
		return true
	end
	local vChildren = uiParent:getChildren()
	for _,v in ipairs(vChildren) do
		local bOk = isChildOf(v, uiChild)
		if bOk then
			return true
		end
	end
	return false
end

-- 提醒图标，统一接口调速率
function performWithNoticeAction(node)
    node:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.ScaleTo:create(0.25, 1.1), cc.ScaleTo:create(0.25, 0.9) )))
end

--根据字体大小大致算出对应的行高
function getLineHeightByFontSize(fontSize)
    return fontSize * 1.31
end

function createTitleLine(parent, pos, width, anchor)
	local rootNode = cc.Node:create()
	rootNode:setPosition(pos)
	rootNode:setContentSize(cc.size(width, 12))

	if anchor then
		rootNode:setAnchorPoint(anchor)
	end

	if parent then
		parent:addChild(rootNode)
	end

	local linePicPath = "res/common/bg/bg27-2.png"
	local texture = cc.Director:getInstance():getTextureCache():addImage(linePicPath)
	if texture == nil then
		return rootNode
	end

	local textureSize = texture:getContentSize()
	local picWidth = textureSize.width
	local picWidthHalf = picWidth * 0.5
	local picHeight = textureSize.height
	local centerWidthHalf = 30
	local scaleWidth = 10
	local edgeWidth = 10

	if picWidth <(centerWidthHalf + scaleWidth + edgeWidth) * 2 then
		return rootNode
	end

	if width <(centerWidthHalf + edgeWidth) * 2 then
		return rootNode
	end

	local scaleLen = width * 0.5 - centerWidthHalf - edgeWidth
	if scaleLen > 0 then
		local spLeftScale = cc.Sprite:create(linePicPath, cc.rect(picWidthHalf - centerWidthHalf - 20, 0, scaleWidth, picHeight))
		spLeftScale:setAnchorPoint(cc.p(0, 0))
		spLeftScale:setPosition(cc.p(edgeWidth, 0))
		spLeftScale:setScaleX(scaleLen / scaleWidth)
		rootNode:addChild(spLeftScale)

		local spRightScale = cc.Sprite:create(linePicPath, cc.rect(picWidthHalf + centerWidthHalf, 0, scaleWidth, picHeight))
		spRightScale:setAnchorPoint(cc.p(0, 0))
		spRightScale:setPosition(cc.p(width * 0.5 + centerWidthHalf, 0))
		spRightScale:setScaleX(scaleLen / scaleWidth)
		rootNode:addChild(spRightScale)
	end

	local centerSpr = cc.Sprite:create(linePicPath, cc.rect(picWidthHalf - centerWidthHalf, 0, centerWidthHalf * 2, 12));
	centerSpr:setAnchorPoint(cc.p(0, 0));
	centerSpr:setPosition(width * 0.5 - centerWidthHalf, 0);
	rootNode:addChild(centerSpr);

	local spLeft = cc.Sprite:create(linePicPath, cc.rect(0, 0, edgeWidth, 12))
	spLeft:setAnchorPoint(cc.p(0, 0))
	spLeft:setPosition(cc.p(0, 0))
	rootNode:addChild(spLeft)

	local spRight = cc.Sprite:create(linePicPath, cc.rect(picWidth - edgeWidth, 0, edgeWidth, 12))
	spRight:setAnchorPoint(cc.p(0, 0))
	spRight:setPosition(cc.p(width - edgeWidth, 0))
	rootNode:addChild(spRight)

	return rootNode
end