local GUIAnalysis={}

-- #PanelObjectData=0
-- #ImageViewObjectData/SpriteObjectData=1
-- #ButtonObjectData=2
-- #TextObjectData=3
-- #TextFieldObjectData=4
-- #CheckBoxObjectData=5
-- #LoadingBarObjectData=6
-- #TouchGroup=7
-- #ScrollViewObjectData=8
-- #ListViewObjectData=9
-- #PageViewObjectData=10
-- #TextBMFontObjectData=11
-- #SliderObjectData=12
-- #RichLabelObjectData=13

local function setNormal(node,d)
	return node:setName(d.n or ""):setPosition(d.x or 0,d.y or 0):setContentSize(cc.size(d.w or 0,d.h or 0)):setVisible(d.v)
		:setAnchorPoint(cc.p(d.ax or 0,d.ay or 0)):setRotation(d.r or 0)
end

local func={
	[0]=function(d)
		local node
		if d.c or d.res then
			node=ccui.Layout:create()
			node:setClippingEnabled(d.c and true or false)
			if d.res then
				node:setBackGroundImageScale9Enabled(true)
				node:setBackGroundImage(d.res, ccui.TextureResType.plistType)
			end
		else
			node=ccui.Widget:create()
		end
		node=setNormal(node,d)
		return node
	end,
	[1]=function(d)
		local node=ccui.ImageView:create()

		if d.zoomImage then
			--图片跟随容器大小变化
			node:setUnifySizeEnabled(false)
			node:ignoreContentAdaptWithSize(false)
		end
		if d.res then
			node:loadTexture(d.res,ccui.TextureResType.plistType)
		end
		if d.ss then
			node:setScale9Enabled(true)
		end

		if d.sx and d.sy and d.sw and d.sh then
			node:setCapInsets(cc.rect(d.sx, d.sy, d.sw, d.sh))
		end
		
		if d.opa then
			node:setOpacity(255 * d.opa)
		end
		
		node=setNormal(node,d)

		return node
	end,
	[2]=function(d)
		local node=ccui.Button:create()
		node:setTitleFontName(FONT_NAME)
		node:getTitleRenderer():enableOutline(cc.c4b(24,19,11,200),1)
		if d.res then
			node:loadTextureNormal(d.res,ccui.TextureResType.plistType)
		end
		if d.sel then
			node:loadTexturePressed(d.sel,ccui.TextureResType.plistType)
		end
		if d.dis and d.dis ~= "null" then
			node:loadTextureDisabled(d.dis,ccui.TextureResType.plistType)
		end
		if d.fs then
			node:setTitleFontSize(d.fs)
		end
		if d.tcolor then
			local param = string.split(d.tcolor, "|")
			if #param == 3 then
				node:setTitleColor(cc.c3b(tonumber(param[1]), tonumber(param[2]), tonumber(param[3])))
			end
		end
		if d.text then
			node:setTitleText(d.text)
		end
		if d.ss then
			node:setScale9Enabled(true)
		end
		if d.sx and d.sy and d.sw and d.sh then
			node:setCapInsets(cc.rect(d.sx, d.sy, d.sw, d.sh))
		end

		if d.opa then
			node:setOpacity(255 * d.opa)
		end
		
		node=setNormal(node,d)

		if d.fr and d.olc and d.ols then
			local cs = string.split(d.olc, ",")
			node:enableOutline(cc.c3b(cs[1],cs[2],cs[3]),d.ols)
		end
		-- 设置字间距
		node:getTitleRenderer():setAdditionalKerning(2)
		return node
	end,
	[3]=function(d)

		local node=ccui.Text:create("", FONT_NAME, 20)

		node:enableOutline(cc.c4b(24,19,11,200),1);
		if d.fs then
			node:setFontSize(d.fs)
		end
		if d.text then
			node:setString(d.text):show()
		end
		if d.color then
			local param = string.split(d.color, "|")
			if #param == 3 then
				node:setColor(cc.c3b(tonumber(param[1]), tonumber(param[2]), tonumber(param[3])))
			end
		end

		if d.w and d.h then
			node:ignoreContentAdaptWithSize(false)
			node:setTextAreaSize(cc.size(d.w or 0,d.h or 0))
		end

		node:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
		if d.ht then
			if d.ht == 1 then
				node:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
			elseif d.ht == 2 then
				node:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_RIGHT)
			end
		end
		node:setTextVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_TOP)
		if d.vt then
			if d.vt == 1 then
				node:setTextVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
			elseif d.vt == 2 then
				node:setTextVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_BOTTOM)
			end
		end
		if d.fr and d.olc and d.ols then
			local cs = string.split(d.olc, ",")
			node:enableOutline(cc.c3b(cs[1],cs[2],cs[3]),d.ols)
		end
		node=setNormal(node,d)
		return node
	end,
	[4]=function(d)

		return nil
	end,
	[5]=function(d)
		local node
		if d.nbf and d.nnf then
			node=ccui.CheckBox:create(d.nbf,d.nnf,ccui.TextureResType.plistType)
		else
			node=ccui.CheckBox:create()
		end
		node=setNormal(node,d)
		node:setSelected(d.selstate)
		node:setTouchEnabled(true)
		return node
	end,
	[6]=function(d)
		local node=ccui.LoadingBar:create()

		if d.res then
			node:loadTexture(d.res, ccui.TextureResType.plistType)
		end

		if d.ss then
			node:setScale9Enabled(true)
		end

		if d.sx and d.sy and d.sw and d.sh then
			node:setCapInsets(cc.rect(d.sx, d.sy, d.sw, d.sh))
		end

		node=setNormal(node,d)

		return node
	end,
	[7]=function(d)
		local node=cc.GuiTabGroup:create()
		node=setNormal(node,d)

		return node
	end,
	[8]=function(d)
		local node=ccui.ScrollView:create()
		node=setNormal(node,d)
		if d.d == 1 then
			node:setDirection(ccui.ScrollViewDir.vertical)
		elseif d.d == 2 then
			node:setDirection(ccui.ScrollViewDir.horizontal)
		end
		node:setScrollBarEnabled(false)
		return node
	end,
	[9]=function(d)
		local node = nil 
		if d.ud then 
			local param = string.split(d.ud, "|")
			if #param == 4 then
				local dir = 1
				if d.d == 2 then dir = 0 end

				local repeatX,repeatY,spaceX,spaceY = tonumber(param[1]),tonumber(param[2]),tonumber(param[3]),tonumber(param[4])
				node = GUITable.new({
					direction = dir,
					listlen = dir == 1 and repeatY or repeatX,
					listspace = dir == 1 and spaceY or spaceX,
					celllen = dir == 1 and repeatX or repeatY,
					cellspace = dir == 1 and spaceX or spaceY,
				})

				node=setNormal(node,d)
				node:reloadData(0, function() end)--手动reload以防没有数据造成cell错位
			end
		else
			node = ccui.ListView:create() 
			node = setNormal(node,d)
			if d.d == 1 then
				node:setDirection(ccui.ListViewDirection.vertical)
			elseif d.d == 2 then
				node:setDirection(ccui.ListViewDirection.horizontal)
			end
			node:setScrollBarEnabled(false)
		end
		return node
	end,
	[10]=function(d)
		local node
		if d.ud and string.find(d.ud,"asyncPageview") then
			node = GUIPageView.new()
		else
			node=ccui.PageView:create()
		end
		node=setNormal(node,d)
		node:setCustomScrollThreshold(node:getContentSize().width / 6)
		return node
	end,
	[11]=function(d)
		return nil
	end,
	[12]=function(d)
		return nil
	end,
	[13]=function (d) --针对richlabel name属性特殊处理
		local vSpace = 8
		if d.ud and string.find(d.ud,"verticalSpace%(.*%)") then
			string.gsub(d.ud,"verticalSpace%((.*)%)",function( n )
				vSpace = n
			end)
		end
		
		local node = GUIRichLabel.new({size = cc.size(d.w or 100, 0), space = vSpace})
		node=setNormal(node,d)
		if d.text then 
			node:setRichLabel(d.text, "label", d.fs or 20) 
		end
		return node
	end
}

local function attachUserData(node,ud)
	if string.find(ud,"tabh%(.+%)") then
		local params = {}
		params.size = node:getContentSize()
		params.style = "horizon";
		params.titles = string.split(string.sub(ud,6,-2), ",");
		local tabHorizon = GUITabView.new(params);
		tabHorizon:setName(node:getName())
		node:setName("tabh")
		node:addChild(tabHorizon);
		node:setTouchEnabled(true):setTouchSwallowEnabled(true)
	end
	if string.find(ud,"tabv%(.+%)") then
		local params = {}
		params.size = node:getContentSize()
		params.style = "vertical";
		params.titles = string.split(string.sub(ud,6,-2), ",");
		local tabVertical = GUITabView.new(params);
		tabVertical:setName(node:getName())
		node:setName("tabv")
		tabVertical:setPositionY(node:getContentSize().height)
		node:addChild(tabVertical);
		node:setTouchEnabled(true):setTouchSwallowEnabled(true)
	end
	if string.find(ud,"GUILoaderBar") then
		node = GUILoaderBar.new({image = node})
	end
	if string.find(ud,"outline%(.*%)") then
		local params = string.split(string.sub(ud,9,-2), ",");
		local color = GameBaseLogic.getColor(tonumber(params[1],16))
		local size = tonumber(params[2])
		node:getTitleRenderer():enableOutline(color, size)
	end
	if string.find(ud,"zoomscale%(.*%)") then
		if node:getDescription() == "Button" then
			string.gsub(ud,"zoomscale%((.*)%)",function( n )
				node:setPressedActionEnabled(true)
				node:setZoomScale(tonumber(n))
				return n
			end)
		end
	end
	if string.find(ud,"underline%(.*%)") then
		local params = string.split(string.sub(ud,11,-2), ",")
		local color = GameBaseLogic.getColor4f(tonumber(params[1],16))
		local width = tonumber(params[2])
		GameUtilSenior.addUnderLine(node, color, width)
	end
	return node
end

local function createWidget(uitab)
	local root=nil
	local temp={}

	for i,v in ipairs(uitab) do
		if v.type and func[v.type] then
			local node=func[v.type](v)
			if node then
				if v.parent and v.parent==0 then
					-- v.v=true -- 根节点强强制可见
					root=node:show()
				end
				if v.id and not temp[v.id] then
					temp[v.id]={p=v.parent,n=node}
				end
				if v.ud then
					local uds = string.split(v.ud,";")
					for p,q in pairs(uds) do
						temp[v.id].n = attachUserData(node,q)
					end
				end
			end
		end
	end

	for i,v in pairs(temp) do
		if v.p and v.p~=0 and temp[v.p] then
			local pNode = temp[v.p].n
			local cNode = v.n
			if cNode:getName() == "render" and pNode.setModel then
				pNode:setModel(cNode)
			else
				pNode:addChild(cNode)
			end
		end
	end
	return root
end

function GUIAnalysis.attachEffect(node,userdata)
	if userdata and #userdata>0 then
		local uds = string.split(userdata,";")
		for p,q in pairs(uds) do
			node = attachUserData(node,q)
		end
	end
	return node
end

function GUIAnalysis.load(file)
	file = string.gsub(file, ".uif", ".lua")
	LUA_RET=nil

	root=nil
	cc.LuaEventListener:executeScriptFile(file)

	if LUA_RET then
		root=createWidget(LUA_RET)
	end

	LUA_RET=nil

	return root
end

return GUIAnalysis