--输出日志--
function log(str)
	Util.Log(str)
end
--错误日志--
function logError(str) 
	Util.LogError(str)
end
--警告日志--
function logWarn(str) 
	Util.LogWarning(str)
end

--查找对象--
function find(str)
	return GameObject.Find(str)
end
function destroy(obj)
	GameObject.Destroy(obj)
end
function destroyImmediate( obj )
	if ToLuaIsNull(obj) then return false end
	if obj and obj.name and GameConst.Debug then
		--print("destroy obj name ==>> ", obj.name)
	end
	GameObject.DestroyImmediate(obj)
	return true
end
function activtyGameObject(go, bool)
	if go then
		go:SetActive(bool)
	end
end
function newObject(prefab)
	return GameObject.Instantiate(prefab)
end
-- userdata(c# long)转 lua 数值
function toLong( v )
	return tonumber(tostring(v or 0))
end
-- 64位字符串str(字符串|整形) 转成 long
function longTo( str )
	return int64.new(tostring(str))
end
-- 彻底销毁 LuaUI对象 或 fui对象
function destroyUI( fui )
	if not fui then return end
	local go = nil
	if not ToLuaIsNull(fui.displayObject) and not ToLuaIsNull(fui.displayObject.gameObject) then
		go = fui.displayObject.gameObject
	end
	fui:Dispose()
	destroyImmediate(go)
end
-- 彻底销毁一个列表中的 UI对象 或 fui对象
function destroyUIList( list )
	if not list or not next(list) then return end
	for _,v in pairs(list) do
		if type(v) == "userdata" then
			destroyUI( v )
		else
			v:Destroy()
		end
	end
end

-- 调度器 类似 cocos2dx scheduler
function stopFuiRender(fui)
	if fui then
		RenderMgr.Realse(fui)
	end
end
-- 为fui注入定时器引擎，ui销毁时自己停止 (interval 表示间隔，最小为当前的帧频时间填写0即可)
-- 作用，可以对UI做异步操作处理，一个个单元处理
function setupFuiRender(fui, callBack, interval)
	if fui then
		RenderMgr.AddInterval(callBack, fui, interval or 0.1)
		fui.onRemovedFromStage:Add(function (e)
			stopFuiRender(fui)
		end)
	end
end
-- 单次调度器(延迟时间delay)
function setupFuiOnceRender(fui, callBack, delay)
	if fui then
		delay = delay or 0.1
		RenderMgr.AddInterval(callBack, fui, delay, delay)
		fui.onRemovedFromStage:Add(function (e)
			RenderMgr.Realse(fui)
		end)
	end
end

-- 长按
function longPress( btn, delayCallback, delay, key, fast)
	delay = delay or 0.3
	key = key or btn
	--local isPress = false
	local doFun = function ()
		delayCallback()
		RenderMgr.SetInterval(key, fast or 0.1)
		--isPress = true
	end
	btn.onTouchBegin:Add(function ()
		key = RenderMgr.AddInterval(doFun, key, delay)
	end)
	btn.onTouchEnd:Add(function ()
		RenderMgr.Realse(key)
		--isPress = false
	end)
	--[[if useOnClick ~= false then
		btn.onClick:Add(function ()
			if isPress then return end
			delayCallback()
		end)
	end]]--
end

-- 将按钮处理成防点击过快 delay 延迟恢复时间， delayLabel 延迟过程时显示的标签
function ButtonToDelayClick(btn, clickCallback, delay, delayLabel)
	if not btn then return end
	delay = delay or 1
	btn.onClick:Add(function (e)
		if btn.data and btn.data==1 then return end
		clickCallback(e)
		btn.data = 1
		local sourceLabel = btn.title
		if delayLabel then
			btn.title = delayLabel
		end
		setupFuiOnceRender(btn, function ()
			btn.data = 2
			if delayLabel then
				btn.title = sourceLabel
			end
		end, delay)
	end)
end

function AddEffectToUI( root, effectName, x, y, scale, tab, key, value )
	if not root then return end
	local effectConn = GGraph.New()
	root:AddChild(effectConn)
	effectConn.x = x
	effectConn.y = y
	EffectMgr.LoadEffect(effectName, function ( eff )
		effectConn:SetNativeObject(GoWrapper.New(eff))
		effectConn.scale = scale
		if tab and key and value then
			tab.eff = eff
			tab.conn = effectConn
			tab[key] = value
		end
	end)
end

-- 延时调用函数
function DelayCall(callBack, delay)
	RenderMgr.AddInterval(callBack, nil, delay, delay)
end

function DelayCallWithKey(callBack ,delay ,key)
	RenderMgr.AddInterval(callBack , key ,delay ,delay)
end
-- 下一帧调用
function NextFrameCall(callBack)
	RenderMgr.DoNextFrame(callBack)
end
-- type：0 圆内随机点 1球面上随机点 2球内随机点 num产生数量 r产生的半径长 center圆心或球心
function GetRandomPoint(type, num, r, center)
	num = num or 1
	if r == nil or r == 0 then r = 1 end
	center = center or (type==0 and Vector2.zero or Vector3.zero)
	local result = {}
	local pos = nil
	for i=1,num do
		if type == 0 then
			pos = Util.RandomInsideUnitCircle() * r + center
		elseif type == 1 then
			pos = Util.RandomOnUnitSphere() * r + center
		else
			pos = Util.RandomInsideUnitSphere() * r + center
		end
		table.insert(result, pos)
	end
	return result
end

function child(str)
	return transform:FindChild(str)
end

function subGet(childNode, typeName)		
	return child(childNode):GetComponent(typeName)
end

-- 对"子级"进行缩放 step为要操作的层级限制, -1表示所有子级都缩放 _max不用填写，内部分析参数
-- 粒子系统使用 Util.ScaleParticleSystem(eff.gameObject, 2)
function scaleChild(transform, scale, step, _max )
	if not transform then return end
	step = step or 0
	local num = transform.childCount
	local i=0 
	while (i<num)
	do
		local node=transform:GetChild(i)
		node.localScale = scale
		i = i + 1
		if node.childCount>0 then
			if step ~= -1 then
				_max = _max or 0
				if _max > step then return end
				scaleChild(node, scale, step, _max+1)
			else
				scaleChild(node, scale, step, _max+1)
			end
		end
	end
end

-- 序列化每个protobuf列表中项的处理并执行回调函数，回调函数参数为list中单元项
function SerialiseProtobufList( list, itemCallback )
	if not list then return end
	local item
	for i=1, table.maxn(list) do
		item = list[i]
		itemCallback(item)
	end
end
-- 序列化每个protobuf列表中项的并收集单元项返回正常的lua列表
function CollectProtobufList( list )
	if not list then return end
	local item
	local result={}
	for i=1, table.maxn(list) do
		result[i] = list[i]
	end
	return result
end


-- ui
	local createModelInfo = {} --{[model] = {asyncLoadCount, hadLoadCount, loadCallback},[model] = {asyncLoadCount, hadLoadCount, loadCallback}...}
	--ui模型创建
		function CreateModel(loadCallback, dressStyle, weaponStyle, wingStyle, weaponEftId)
			local callback = function ( o )
				if o == nil then return end
				local playerModel = GameObject.Instantiate(o)
				playerModel.name = dressStyle
				playerModel.transform.localScale = Vector3.one
				playerModel.transform.localPosition = Vector3.zero
				playerModel.transform.localRotation = Quaternion.identity

				local asyncLoadCount = 0
				if weaponStyle ~= nil and weaponStyle ~= 0 then
					asyncLoadCount = asyncLoadCount + 1
				end
				if wingStyle ~= nil and wingStyle ~= 0 then
					asyncLoadCount = asyncLoadCount + 1
				end
				if weaponEftId ~= nil and weaponEftId ~= 0 then
					asyncLoadCount = asyncLoadCount + 1
				end
				createModelInfo[playerModel] = {asyncLoadCount, 0, loadCallback}

				if weaponStyle ~= nil and weaponStyle ~= 0 then
					TakeOnWeapon(playerModel, weaponStyle)
				end
				if wingStyle ~= nil and wingStyle ~= 0 then
					SetWing(playerModel, wingStyle)
				end
				if weaponEftId ~= nil and weaponEftId ~= 0 then
					SetWeaponLight(playerModel, weaponEftId)
				end

				return playerModel
			end
			LoadPlayer(dressStyle, callback)
		end

		function TakeOnWeapon(model, creatureID)
			local parentTran = model.transform:Find("weapon01")--获取节点
			if not parentTran then error("没有找到 weanpon01 的模型节点!") return end
			LoadWeapon(creatureID, function ( o )
				if o == nil or ToLuaIsNull(parentTran) then return end
				weapon = GameObject.Instantiate(o)
				weapon.name = creatureID
				local tf = weapon.transform
				tf.parent = parentTran
				tf.localPosition = Vector3.zero
				tf.localRotation = Quaternion.identity
				tf.localScale = Vector3.one
				layerMgr:SetTransformChildLayer(tf,"UI")

				createModelInfo[model][2] = createModelInfo[model][2] + 1
				CheckLoadCallBack(model)
			end)
		end

		function SetWeaponLight(model, effectId)
			local parentTran = model.transform:Find("weapon01")--获取节点
			if ToLuaIsNull(parentTran) then error("没有找到 weanpon01 的模型节点!") return end
			EffectMgr.LoadEffect(effectId, function(eft)
				if ToLuaIsNull(parentTran) then destroyImmediate(eft) return end
				if ToLuaIsNull(eft) then return end
				local tf = eft.transform
			 	tf.parent = parentTran
				tf.localPosition = Vector3.zero
				tf.localRotation = Quaternion.identity
				tf.localScale = Vector3.one
				layerMgr:SetTransformChildLayer(tf,"UI")

				createModelInfo[model][2] = createModelInfo[model][2] + 1
				CheckLoadCallBack(model)
			end)
		end

		function SetWing(model, wingStyle)
			local wingRoot = Util.GetChild(model.transform, "wing")
			if ToLuaIsNull(wingRoot) then error("没有找到 wing 的模型节点!") return end
			if wingRoot == nil then return end
			LoadWing(wingStyle, function ( o )
				if ToLuaIsNull(o) or ToLuaIsNull(wingRoot) then return end 
				wingEntity = GameObject.Instantiate(o)
				local tf = wingEntity.transform
				wingEntity.name = StringFormat("{0}", wingStyle)
				tf.parent = wingRoot
				tf.localPosition = Vector3.zero
				tf.localRotation = Quaternion.identity
				tf.localScale = Vector3.one
				layerMgr:SetTransformChildLayer(tf,"UI")

				createModelInfo[model][2] = createModelInfo[model][2] + 1
				CheckLoadCallBack(model)
			end)
		end

		function CheckLoadCallBack(model)
			if createModelInfo[model][2] == createModelInfo[model][1] then
				createModelInfo[model][3](model)
				createModelInfo[model] = nil
			end
		end
	--

	-- 列表生成
	--[[以 PkgCell类 创建一个格子列表
		root容器 生成 total 个， rowNum 每行N个 cellW, cellH 单元大小, cellClickCallback 点击回调, offx , offy 偏移位置 
		返回格子列表grids（以格子位置id为key 以格子UI单元为value）totalW, totalH 滚动面板的大小  starIdx 起始创建位置 ]]
	function CreatePkgCellGrid(root, total, rowNum, cellW, cellH, offx, offy, cellClickCallback, starIdx)
		offx = offx or 10
		offy = offy or 10
		cellW = cellW or 105
		cellH = cellH or 105
		rowNum = rowNum or 5
		starIdx = math.max(starIdx or 0, 0)
		local grids = {}
		local r, c = 0, 0
		for i=starIdx+1, total+starIdx do
			local cell = PkgCell.New(root, nil, cellClickCallback)
			r = math.floor((i-1)%rowNum)
			c = math.floor((i-1)/rowNum)
			cell:AddCellBg()
			cell:SetXY(r*cellW+offx, c*cellH+offy)
			cell:SetRare(0) -- 空格背景
			cell.gid = i -- 位置
			cell:SetupPressShowTips(true)
			table.insert(grids, cell)
			-- cell:SetNum(i) cell:ShowRed(true) cell:AddArrow("Icon/Other/arrow_"..(c%2)..(i%2)) cell:ShowArrow(true) cell:AddLock() cell:SetLock(true) cell:AddBind() cell:SetBind(true) if i%2 == 1 then cell:SetIcon(1, 1100102) else 	cell:SetIcon(2, 21200) end if i%7 ~= 0 then 	cell:SetRare(i%7-1) end
		end
		return grids
	end
	--[[uiClass 
		1.luaUI子类：SetXY(x, y)处理位置接口, id：格子id
		2.fui资源Url:通过 UIPackage.GetItemURL("包名","图片名") 得到url， 格子对象data 为格子id ]]
	function CreateCustomGrid(root, uiClass, total, rowNum, cellW, cellH, offx, offy, cellClickCallback, starIdx)
		offx = offx or 4
		offy = offy or 4
		cellW = cellW or 80
		cellH = cellH or 80
		rowNum = rowNum or 2
		starIdx = math.max(starIdx or 0, 0)
		local grids = {}
		local r, c = 0, 0
		local t = type(uiClass)
		if t == "table" then -- luaUI
			for i=starIdx+1, total+starIdx do
				local cell = uiClass.New()
				root:AddChild(cell.ui)
				cell.id = i
				r = math.floor((i-1)%rowNum)
				c = math.floor((i-1)/rowNum)
				cell:SetXY(r*cellW+offx, c*cellH+offy)
				if cellClickCallback then cell.ui.onClick:Add(function (e) cellClickCallback(cell) end) end
				table.insert(grids, cell)
			end
		elseif t == "string" then -- fui url
			for i=starIdx+1, total+starIdx do
				local cell = UIPackage.CreateObjectFromURL(uiClass)
				r = math.floor((i-1)%rowNum)
				c = math.floor((i-1)/rowNum)
				cell:SetXY(r*cellW+offx, c*cellH+offy)
				cell.data = i
				cell.onClick:Add(function (e) cellClickCallback(cell) end)
				root:AddChild(cell)
				table.insert(grids, cell)
			end
		else print("不能创建格子列表!!!") end
		return grids
	end
	--[[异步动态生成格子列表， num 生成个数 addedCallback 一个单元回调]]
	function CreateAsyncGrid(root, uiClass, num, rowNum, cellW, cellH, offx, offy, cellClickCallback, starIdx, addedCallback)
		offx = offx or 4
		offy = offy or 4
		cellW = cellW or 80
		cellH = cellH or 80
		rowNum = rowNum or 2
		starIdx = math.max(starIdx or 0, 0)
		local r, c = 0, 0
		local t = type(uiClass)
		local i = 1
		local pos = 0
		local function renderCell()
			if i <= num then
				pos = i+starIdx
				local cell = nil
				if t == "table" then -- luaUI
					cell = uiClass.New()
					cell.id = pos
					if cellClickCallback then cell.ui.onClick:Add(function (e) cellClickCallback(cell) end) end
					root:AddChild(cell.ui)
				elseif t == "string" then -- fui url
					cell = UIPackage.CreateObjectFromURL(uiClass)
					cell.data = pos
					cell.onClick:Add(function (e) cellClickCallback(cell) end)
					root:AddChild(cell)
				else print("不能创建格子列表!!!") end
				r = math.floor((pos-1)%rowNum)
				c = math.floor((pos-1)/rowNum)
				cell:SetXY(r*cellW+offx, c*cellH+offy)
				if addedCallback then addedCallback(cell) end
				i=i+1
			else
				stopFuiRender(root)
			end
		end
		setupFuiRender(root, renderCell, 0.01)
	end

	-- txt
	function createText( content, x, y, width, height, fontSize, fontPkg, fontName, color, bold, ubb, root )
		local txt = GTextField.New()
		local tf = txt.textFormat
		if bold ~= nil then tf.bold = bold end
		tf.size = fontSize or 20
		tf.color = color or newColorByString("d4dcfe")
		if fontPkg and fontName then tf.font = UIPackage.GetItemURL(fontPkg , fontName) end
		txt.textFormat = tf
		if ubb ~= nil then txt.UBBEnabled = ubb end
		if content then txt.text = content end
		if x then txt.x = x end
		if y then txt.y = y end
		if width then txt.width = width end
		if height then txt.height = height end
		if root then root:AddChild(txt) end
		return txt
	end
	function createText0( content, root, x, y, width, height, fontPkg, fontName )
		return createText( content, x, y, width, height, nil, fontPkg, fontName, nil, nil, nil, root )
	end
	function createText1( content, root, x, y, width, height)
		return createText( content, x, y, width, height, nil, nil, nil, nil, nil, nil, root )
	end
	function createText2( content, root, x, y, width, height, ubb)
		return createText( content, x, y, width, height, nil, nil, nil, nil, nil, ubb, root )
	end
	function createRichText( content, x, y, width, height, fontSize, fontPkg, fontName, color, bold, ubb, root )
		local txt = GRichTextField.New()
		local tf = txt.textFormat
		if bold ~= nil then tf.bold = bold end
		tf.size = fontSize or 20
		tf.color = color or newColorByString("d4dcfe")
		if fontPkg and fontName then tf.font = UIPackage.GetItemURL(fontPkg , fontName) end
		txt.textFormat = tf
		if ubb ~= nil then txt.UBBEnabled = ubb end
		if content then txt.text = content end
		if x then txt.x = x end
		if y then txt.y = y end
		if width then txt.width = width end
		if height then txt.height = height end
		root:AddChild(txt)
		return txt
	end
	function createRichText0( content, root, x, y, width, height, fontPkg, fontName )
		return createRichText( content, x, y, width, height, nil, fontPkg, fontName, nil, nil, nil, root )
	end
	function createRichText1( content, root, x, y, width, height)
		return createRichText( content, x, y, width, height, nil, nil, nil, nil, nil, nil, root )
	end
	function createRichText2( content, root, x, y, width, height, ubb)
		return createRichText( content, x, y, width, height, nil, nil, nil, nil, nil, ubb, root )
	end
	function setTxtAutoSizeType( txt, t )
		if not txt then return end
		if t == 1 then
			t = FairyGUI.AutoSizeType.Both
		elseif t == 2 then
			t = FairyGUI.AutoSizeType.Height
		elseif t == 3 then
			t = FairyGUI.AutoSizeType.Shrink
		else
			t = FairyGUI.AutoSizeType.None
		end
		txt.autoSize = t
	end
	function setTxtAlignType( txt, t )
		if not txt then return end
		if t == 1 then
			t = FairyGUI.AlignType.Center
		elseif t == 2 then
			t = FairyGUI.AlignType.Right
		else
			t = FairyGUI.AlignType.Left
		end
		txt.align = t
	end
	function setTxtVertAlignType( txt, t )
		if not txt then return end
		if t == 1 then
			t = FairyGUI.VertAlignType.Middle
		elseif t == 2 then
			t = FairyGUI.VertAlignType.Bottom
		else
			t = FairyGUI.VertAlignType.Top
		end
		txt.verticalAlign = t
	end
	function setTxtFontOrSize( txt, font, size, color )
		if not txt then return end
		local tf = txt.textFormat
		if font then tf.font = font end
		if size then tf.size = size end
		if color then tf.color = color end
		txt.textFormat = tf
	end
	function setTxtSize( txt, size, color )
		if not txt then return end
		local tf = txt.textFormat
		if size then tf.size = size end
		if color then tf.color = color end
		txt.textFormat = tf
	end
	--[[设置富文本内容图文显示(对 GRichTextField 对象启动 .UBBEnabled = true 即可以实现)
		"txtContent[img=width,height]imgUrl可以是res下的也可以是ui:// 也可以是http:// 的[/img]content[url=value]xxxxx[/url][color=%s]%s[/color]..."
		如：这是张图片[img=200,100]Icon/Goods/diamond[/img]
	]]
	function setRichTextContent(txt, content)
		if not txt then return end
		txt.text = UBBParserExtension:Parse(content or "") --  "[img=200,100]Icon/Goods/diamond[/img]"
	end
	function getRichTextContent(content)
		return UBBParserExtension:Parse(content or "")
	end
	function setImgFillType( gLoader, t )
		if not gLoader then return end
		if t == 1 then
			t = FairyGUI.VertAlignType.Scale
		elseif t == 2 then
			t = FairyGUI.VertAlignType.ScaleMatchHeight
		elseif t == 3 then
			t = FairyGUI.VertAlignType.ScaleMatchWidth
		elseif t == 4 then
			t = FairyGUI.VertAlignType.ScaleFree
		else
			t = FairyGUI.VertAlignType.None
		end
		gLoader.fill = t
	end
	function getGiftDesc(content, tinyType, effectValue)
		if tinyType == GoodsVo.TinyType.gift and effectValue then -- 礼包处理
			local giftCfg = GetCfgData("gift"):Get(effectValue)
			local career = LoginModel:GetInstance():GetLoginRole().career
			if giftCfg and giftCfg.reward then
				local s = ""
				local rewardList = {}
				for i,v in ipairs(giftCfg.reward) do
					if v[1]==0 or v[1]==career then
						table.insert(rewardList, v)
					end
				end
				local list = {}
				for i,v in ipairs(rewardList) do
					local num = v[5]
					local cfg = GoodsVo.GetCfg(v[3], v[4])
					if cfg then
						local c = StringFormat("[color={0}]{1}[/color]x{2}", GoodsVo.RareColor[cfg.rare], cfg.name, num)
						table.insert(list, c)
					end
				end
				content = StringFormatII(content, list)
			end
		end
		return content
	end

	-- 属性对比 a, b 属性列表
	function compareAttrs( a, b )
		a = a or {}
		b = b or {}
		local result = {} -- [i]={name, val, upVal, id})
		for _,v1 in ipairs(a) do
			local id = v1[1]
			local val = v1[2]
			local upVal = val
			local name = RoleVo.GetPropDefine(id).name
			for _,v2 in ipairs(b) do
				if v2[1] == id then
					upVal = val-v2[2]
					break
				end
			end
			table.insert(result, {name, val, upVal, id})
		end
		return result
	end

	-- tabbar
	--[[
		root : 容器UI
		tabs:tabbar 数据{{label="", id="0", res0="", res1="", red=true, icon="", iconX=nil, iconY=nil bg="", fontSize=nil, fontColor=nil, fontFace=nil}...} 
					[9宫格res 要使用fui中导出9宫格式的，使用接口  UIPackage.GetItemURL("包名","图片名")]
		x, y :位置
		t : 0 垂直 1 水平
		tabCallback : 标签回调
		offSet : 间距
		defaultSelectIdx: 默认选中(选空则不选中)
		cellW, cellH :为bar自定义大小
		返回控制器及tabbar列表，每个tabbar的data就是其中的id作为识别用
	]]
	function CreateTabbar( root, t, tabCallback, tabs, x, y, defaultSelectIdx, offSet, cellW, cellH)
		if not tabs then return end
		local defaultSelectIdx = tonumber(defaultSelectIdx)
		local ctrl = Controller.New()
		root:AddController(ctrl)
		x = x or 0
		y = y or 0
		offSet = offSet or 0
		local tabbarList = {}
		for i, v in ipairs(tabs) do
			local bar = UIPackage.CreateObject("Common" , "CustomTabbarBtn")
			if v.label then bar.title = v.label end
			if v.res0 and v.res0 ~= "" then bar:GetChild("layer0").url = v.res0 end
			if v.res1 and v.res1 ~= "" then bar:GetChild("layer1").url = v.res1 end
			if v.bg and v.bg ~= "" then bar:GetChild("bg").url = v.bg end
			if v.icon and v.icon ~= "" then bar:GetChild("icon").url = v.icon end
			if v.iconX then bar:GetChild("icon").x = v.iconX end
			if v.iconY then bar:GetChild("icon").y = v.iconY end
			if v.fontSize or v.fontColor or v.fontFace then
				setTxtFontOrSize( bar:GetChild("title"), v.fontFace, v.fontSize, v.fontColor ) 
			end

			bar:GetChild("red").visible = v.red == true
			bar.data = tostring(v.id or i)
			if cellW then bar.width = cellW end
			if cellH then bar.height = cellH end
			tabbarList[i] = bar
			if t == 0 then
				bar.x = x
				bar.y = (i-1) * (offSet or cellH or 46) + y
			else
				bar.x = (i-1) * (offSet or cellW or 111) + x
				bar.y = y
			end
			root:AddChild(bar)
			ctrl:AddPage(tostring(bar.data))
			bar.relatedController = ctrl
			bar.pageOption.id = tostring(bar.data)
			bar.pageOption.name = tostring(bar.data)
			bar.pageOption.index = i-1
			if i == 1 and defaultSelectIdx == 0 then
				bar.selected = true
				if tabCallback then
					tabCallback(ctrl.selectedIndex, ctrl.selectedPage, bar)
				end
			end
		end
		ctrl.onChanged:Add(function ()
			EffectMgr.PlaySound("731001")
			if tabCallback then
				tabCallback(ctrl.selectedIndex, ctrl.selectedPage, tabbarList[ctrl.selectedIndex+1])
			end
		end)
		if defaultSelectIdx then
			ctrl.selectedIndex = defaultSelectIdx
		end

		return ctrl, tabbarList
	end
	-- 设置标签红点信息
	function SetTabRedTips(tabs, id, bool )
		if not tabs then return end
		for _,v in ipairs(tabs) do
			if v.data == id then
				v:GetChild("red").visible = bool == true
				break
			end
		end
	end
	-- 设置标签icon
	function SetTabIcon(tabs, id, res, x, y)
		if not tabs then return end
		for _,v in ipairs(tabs) do
			if v.data == id then
				local icon = v:GetChild("icon")
				if res then icon.url = res end
				if x then icon.x = x end
				if y then icon.y = y end
				break
			end
		end
	end
	-- 显示隐藏Tab状态
	function ShowTabbar(tabs, ids, bool)
		if not tabs then return end
		local allPos = {}
		for i,v in ipairs(tabs) do
			if type(ids) ~= "table" then
				local id = ids
				if v.data == id then
					v.visible = bool == true
				end
			else
				for j=1,#ids do
					if v.data == ids[j] then
						v.visible = bool == true
						break
					end
				end
			end
			table.insert(allPos, {x=v.x, y=v.y})
		end
		if #allPos <= 1 then return end
		if allPos[1].x ~= allPos[2].x then
			SortTableByKey(allPos, "x", true)
		else
			SortTableByKey(allPos, "y", true)
		end
		for i,v in ipairs(tabs) do
			local p = nil
			if v.visible then
				p = table.remove(allPos, 1)
				v:SetXY(p.x, p.y)
			else
				p = table.remove(allPos, #allPos)
				v:SetXY(p.x, p.y)
			end
		end
	end
	-- 通过id获取选项卡索引
	function GetTabbarIdxById( tabs, id )
		if not tabs then return 0 end
		for i,v in ipairs(tabs) do
			if v.data == id then
				return i-1
			end
		end
		return 0
	end
	-- 通过id设置标签项
	function SelectTabbarById(ctrl, tabs, id)
		if not ctrl or not tabs or #tabs == 0 then return end
		ctrl.selectedIndex = GetTabbarIdxById( tabs, id )
	end
	-- 设置对有红点的UI显示状态设置
	function SetUIRedTips(fui, id, bool )
		if not fui then return end
		if fui:GetChild("red") then
			fui:GetChild("red").visible = bool == true
		end
	end

	--计算评分(时装)
	--@param propertys [[pId,pValue], [pId,pValue]...]
	function CalculateScore(propertys)
		local result = 0
		for i = 1, #propertys do
			local pId = propertys[i][1]
			local pValue = propertys[i][2]
			if pId == 1 then --最大Hp
				result = result + pValue
			end
			if pId == 3 then --最大Mp
				result = result + pValue
			end
			if pId == 5 then --物理攻击
				result = result + pValue*10
			end
			if pId == 7 then --法术攻击
				result = result + pValue*10
			end
			if pId == 9 then --物理防御
				result = result + pValue*10
			end
			if pId == 11 then --法术防御
				result = result + pValue*10
			end
			if pId == 13 then --暴击
				result = result + pValue*10
			end
			if pId == 15 then --韧性
				result = result + pValue*10
			end
			if pId == 21 then --伤害加深
				result = result + pValue
			end
			if pId == 22 then --伤害减免
				result = result + pValue
			end
			if pId == 23 then --伤害暴击
				result = result + pValue*0.5
			end
			if pId == 31 then --力量
				result = result + pValue*14
			end
			if pId == 32 then --智慧
				result = result + pValue*12
			end
			if pId == 33 then --耐力
				result = result + pValue*20
			end
			if pId == 34 then --灵力
				result = result + pValue*15
			end
			if pId == 35 then --幸运
				result = result + pValue*20
			end
		end

		return math.floor(result)
	end

	-- 邀请组队喊话(弹出)
	--[[
		x, y : 按钮边缘距离边框的距离
		其他参数与 CreateTabbar 一致
	]]
	function CreatePopTabs( t, tabCallback, tabs, x, y, defaultSelectIdx, offSet, cellW, cellH)
		if (not tabs) then return end
		--底框
		local root = UIPackage.CreateObject("Common", "CustomSprite")
		local bgIcon = root:GetChild("icon")
		bgIcon.url = UIPackage.GetItemURL("Common", "shanglakuang")

		local ctrl, tabbarList = CreateTabbar( root, t, tabCallback, tabs, x, y, defaultSelectIdx, offSet, cellW, cellH)
		--距离边框的自适应
		local tmpW = 111
		local tmpH = 46
		if tabbarList[1] then
			tmpW = tabbarList[1].width
			tmpH = tabbarList[1].height
		end
		local delta = 0
		if #tabs > 0 and offSet then
			delta = (#tabs - 1) * offSet
		end
		if t == 0 then
			root.width = x * 2 + tmpW
			root.height = y * 2 + tmpH + delta
		else
			root.width = x * 2 + tmpW + delta
			root.height = y * 2 + tmpH
		end
		return root
	end

------------------------------------------------------ game engine ---------------------------------------------------
-- table-----
	function clone(object)
		local lookup_table = {}
		local function _copy(object)
			if type(object) ~= "table" then
				return object
			elseif lookup_table[object] then
				return lookup_table[object]
			end
			local new_table = {}
			lookup_table[object] = new_table
			for key, value in pairs(object) do
				new_table[_copy(key)] = _copy(value)
			end
			return setmetatable(new_table, getmetatable(object))
		end
		return _copy(object)
	end

	function copyToClass(target, result)
		for k,v in pairs(target) do
			if type(v) ~= "function" and k ~= "_class_type" then
				result[k] = v
			end
		end
	end
	function copyData(target, result)
		for k,v in pairs(target) do
			result[k] = v
		end
	end

	function table.nums(t)
		local count = 0
		for k, v in pairs(t) do
			count = count + 1
		end
		return count
	end

	function table.keys(hashtable)
		local keys = {}
		for k, v in pairs(hashtable) do
			keys[#keys + 1] = k
		end
		return keys
	end

	function table.values(hashtable)
		local values = {}
		for k, v in pairs(hashtable) do
			values[#values + 1] = v
		end
		return values
	end

	function table.merge(dest, src)
		for k, v in pairs(src) do
			dest[k] = v
		end
	end

	function table.insertto(dest, src, begin)
		begin = checkint(begin)
		if begin <= 0 then
			begin = #dest + 1
		end

		local len = #src
		for i = 0, len - 1 do
			dest[i + begin] = src[i + 1]
		end
	end

	function table.indexof(array, value, begin)
		for i = begin or 1, #array do
			if array[i] == value then return i end
		end
		return false
	end

	function table.keyof(hashtable, value)
		for k, v in pairs(hashtable) do
			if v == value then return k end
		end
		return nil
	end

	function table.removebyvalue(array, value, removeall)
		local c, i, max = 0, 1, #array
		while i <= max do
			if array[i] == value then
				table.remove(array, i)
				c = c + 1
				i = i - 1
				max = max - 1
				if not removeall then break end
			end
			i = i + 1
		end
		return c
	end

	function table.map(t, fn)
		for k, v in pairs(t) do
			t[k] = fn(v, k)
		end
	end

	function table.walk(t, fn)
		for k,v in pairs(t) do
			fn(v, k)
		end
	end

	function table.filter(t, fn)
		for k, v in pairs(t) do
			if not fn(v, k) then t[k] = nil end
		end
	end

	function table.unique(t, bArray)
		local check = {}
		local n = {}
		local idx = 1
		for k, v in pairs(t) do
			if not check[v] then
				if bArray then
					n[idx] = v
					idx = idx + 1
				else
					n[k] = v
				end
				check[v] = true
			end
		end
		return n
	end
	
	-- 排序(默认降序)
	function SortTableByKey( list, key, up )
		if up then
			table.sort(list, function(a,b) return a[key]<b[key] end )
		else
			table.sort(list, function(a,b) return a[key]>b[key] end )
		end
	end
	-- 排序(默认降序)
	function SortTableBy2Key( list, key1, key2, up1, up2 )
		if up1 then
			table.sort(list, function(a,b)
						if a[key1] == b[key1] then
							if up2 then
								return a[key2]<b[key2]
							else
								return a[key2]>b[key2]
							end
						else
							return a[key1]<b[key1]
						end
					end )
		else
			table.sort(list, function(a,b)
					if a[key1] == b[key1] then
						if up2 then
							return a[key2]<b[key2]
						else
							return a[key2]>b[key2]
						end
					else
						return a[key1]>b[key1]
					end
				end )
		end
	end
	-- 排序(默认降序)
	function SortTableBy3Key( list, key1, key2, key3, up1, up2, up3 )
		if up1 then
			table.sort(list, function(a,b)
					if a[key1] == b[key1] then
						if up2 then
							if a[key2] == b[key2] then
								if up3 then
									return a[key3]<b[key3]
								else
									return a[key3]>b[key3]
								end
							else
								return a[key2]<b[key2]
							end
						else
							return a[key2]>b[key2]
						end
					else
						return a[key1]<b[key1]
					end
				end )
		else
			table.sort(list, function(a,b)
					if a[key1] == b[key1] then
						if up2 then
							if a[key2] == b[key2] then
								if up3 then
									return a[key3]<b[key3]
								else
									return a[key3]>b[key3]
								end
							else
								return a[key2]<b[key2]
							end
						else
							return a[key2]>b[key2]
						end
					else
						return a[key1]>b[key1]
					end
				end )
		end
	end
	function TableIsEmpty(t)
		return t == nil or next(t) == nil
	end
	-- cs 或 unity 对象是否为空
	function ToLuaIsNull(v)
		return v==nil or tolua.isnull(v)
	end

-- string------
	string._htmlspecialchars_set = {}
	string._htmlspecialchars_set["&"] = "&amp;"
	string._htmlspecialchars_set["\""] = "&quot;"
	string._htmlspecialchars_set["'"] = "&#039;"
	string._htmlspecialchars_set["<"] = "&lt;"
	string._htmlspecialchars_set[">"] = "&gt;"

	function string.htmlspecialchars(input)
		for k, v in pairs(string._htmlspecialchars_set) do
			input = string.gsub(input, k, v)
		end
		return input
	end

	function string.restorehtmlspecialchars(input)
		for k, v in pairs(string._htmlspecialchars_set) do
			input = string.gsub(input, v, k)
		end
		return input
	end

	function string.nl2br(input)
		return string.gsub(input, "\n", "<br />")
	end

	function string.text2html(input)
		input = string.gsub(input, "\t", "	")
		input = string.htmlspecialchars(input)
		input = string.gsub(input, " ", "&nbsp;")
		input = string.nl2br(input)
		return input
	end

	function string.split(input, delimiter)
		input = tostring(input)
		delimiter = tostring(delimiter)
		if (delimiter=='') then return false end
		local pos,arr = 0, {}
		-- for each divider found
		for st,sp in function() return string.find(input, delimiter, pos, true) end do
			table.insert(arr, string.sub(input, pos, st - 1))
			pos = sp + 1
		end
		table.insert(arr, string.sub(input, pos))
		return arr
	end

	function string.ltrim(input)
		return string.gsub(input, "^[ \t\n\r]+", "")
	end

	function string.rtrim(input)
		return string.gsub(input, "[ \t\n\r]+$", "")
	end

	function string.trim(input)
		if not input then return "" end
		input = string.gsub(input, "^[ \t\n\r]+", "")
		return string.gsub(input, "[ \t\n\r]+$", "")
	end

	function string.ucfirst(input)
		return string.upper(string.sub(input, 1, 1)) .. string.sub(input, 2)
	end

	local function urlencodechar(char)
		return "%" .. string.format("%02X", string.byte(char))
	end
	function string.urlencode(input)
		-- convert line endings
		input = string.gsub(tostring(input), "\n", "\r\n")
		-- escape all characters but alphanumeric, '.' and '-'
		input = string.gsub(input, "([^%w%.%- ])", urlencodechar)
		-- convert spaces to "+" symbols
		return string.gsub(input, " ", "+")
	end

	function string.urldecode(input)
		input = string.gsub (input, "+", " ")
		input = string.gsub (input, "%%(%x%x)", function(h) return string.char(checknumber(h,16)) end)
		input = string.gsub (input, "\r\n", "\n")
		return input
	end

	function string.utf8len(input)
		local len  = string.len(input)
		local left = len
		local cnt  = 0
		local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
		while left ~= 0 do
			local tmp = string.byte(input, -left)
			local i   = #arr
			while arr[i] do
				if tmp >= arr[i] then
					left = left - i
					break
				end
				i = i - 1
			end
			cnt = cnt + 1
		end
		return cnt
	end

	function string.formatnumberthousands(num)
		local formatted = tostring(checknumber(num))
		local k
		while true do
			formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
			if k == 0 then break end
		end
		return formatted
	end

-- debug---
	-- 跟踪事件流程
	function debugFollow()
		print(debug.traceback())
	end

	-- 打印调用文件和行数
	function printParent(lev)
		lev = lev or 2
		local track_info = debug.getinfo(lev, "Sln")
		local parent = string.match(track_info.short_src, '[^"]+.lua')	 -- 之前调用的文件
		print(string.format("From %s:%d in function `%s`", parent or "", track_info.currentline or "", track_info.name or ""))
	end

	-- 打印所有父级lua调用信息
	function printPreCall(lev, noPrint)  
		local ret = ""  
		local level = lev or 2  
		ret = ret .. "root:\n"  
		while true do  
			local info = debug.getinfo(level, "Sln")  
			if not info then break end  
			if info.what == "C" then				-- C function  
				ret = ret .. "	" .. tostring(level) .. "C function\n"  
			else		   -- Lua function  
				local parent = string.match(info.short_src, '[^"]+.lua')	 -- 之前调用的文件
				ret = ret .. string.format("	%s:%d in function `%s`\n", parent, info.currentline, info.name or "")  
			end  
			level = level + 1
		end  
		if not noPrint then
			print(ret) 
		else
			return ret
		end
	end 

	-- 让其显示栈上所有的局部变量
	function tracebackex(lev)  
		local ret = ""  
		local level = lev or 2  
		ret = ret .. "Stack info:\n"  
		while true do  
		   --get stack info  
		   local info = debug.getinfo(level, "Sln")  
		   if not info then break end  
		   if info.what == "C" then				-- C function  
			  ret = ret .. tostring(level) .. "\tC function\n"  
		   else		   -- Lua function  
			  ret = ret .. string.format("\t[%s]:%d in function `%s`\n", info.short_src, info.currentline, info.name or "")  
		   end  
		   --get local vars  
		   local i = 1  
		   while true do  
			  local name, value = debug.getlocal(level, i)  
			  if not name then break end  
			  ret = ret .. "\t\t" .. name .. " =\t" .. tostringex(value, 3) .. "\n"  
			  i = i + 1  
		   end	
		   level = level + 1  
		end  
		print(ret)  
	end  
	  
	-- 调用过程中显示栈上所有的局部变量()
	function tostringex(v, len)
		if len == nil then len = 0 end  
		local pre = string.rep('\t', len)  
		local ret = ""  
		if type(v) == "table" then  
		   if len > 5 then return "\t{ ... }" end  
		   local t = ""  
		   for k, v1 in pairs(v) do  
			  t = t .. "\n\t" .. pre .. tostring(k) .. ":"  
			  t = t .. tostringex(v1, len + 1)  
		   end  
		   if t == "" then  
			  ret = ret .. pre .. "{ }\t(" .. tostring(v) .. ")"  
		   else  
			  if len > 0 then  
				ret = ret .. "\t(" .. tostring(v) .. ")\n"  
			  end  
			  ret = ret .. pre .. "{" .. t .. "\n" .. pre .. "}"  
		   end  
		else  
		   ret = ret .. pre .. tostring(v) .. "\t(" .. type(v) .. ")"  
		end  
		return ret  
	end

	--[[ 遍历table
		lua_table 打印的lua数据
		limit 打印表中的层级数限制（nil 表示 到第8层）
		indent__ 显示匿名表头键值启始值 (此参数不要填写)
		step__ 层级打印定义增加 (此参数不要填写)
	--]]
	function _printt (lua_table, limit, indent__, step__)
		step__ = step__ or 0
		indent__ = indent__ or 0
		local content__ = ""
		if  limit ~= nil then
			if step__ > limit then
				return " ..."
			end
		end
		if step__ > 8 then
			return content__.." ..."
		end

		if lua_table == nil then
			return "nil"
		end

		if type(lua_table) == "userdata" or type(lua_table) == "lightuserdata" or type(lua_table) == "thread" then
			return tostring(lua_table)
		end

		if type(lua_table) == "string" or type(lua_table) == "number" then 
			return "[No-Table]: " .. lua_table
		end
		
		for k, v in pairs(lua_table) do
			if k ~= "_class_type" then
				local szSuffix = ""
				TypeV = type(v)
				if TypeV == "table" then
					szSuffix = "{"
				end
				local szPrefix = string.rep("  ", indent__)

				if TypeV == "table" and v._fields then
					local kk, vv = next(v._fields)
					if type(vv) == "table" then
						content__ =content__ .."\n\t"..kk.name.."={".. _printt(vv._fields, 5, indent__ + 1, step__ + 1).."}"
					else
						content__ =content__ .."\n\t"..kk.name.."=".. vv
					end
					-- content__ = content__ .."\n\t".._printt(v._fields, 0, indent__ + 1, step__ + 1)
				else
					if type(k) == "table" then
						if k.name then
							if type(v) ~= "table" then
								content__ = content__.."\n".. k.name.." = "..v
							else
								content__ = content__.."\n".. k.name.." = list:"
								local tmp = "\n"
								for ka,va in ipairs(v) do
									tmp = tmp.."#"..ka.."-"..tostring(va)
								end
								content__ = content__..tmp
							end
						end 
					elseif type(k) == "function" then
						content__ = content__.."\n fun = function"
					else
						formatting = szPrefix..tostring(k).." = "..szSuffix
						if TypeV == "table" then
							content__ = content__.. "\n"..formatting
							content__ = content__ .. _printt(v, limit, indent__ + 1, step__ + 1)
							content__ = content__.. "\n"..szPrefix.."},"
						else
							local szValue = ""
							if TypeV == "string" then
								szValue = string.format("%q", v)
							else
								szValue = tostring(v)
							end
							-- print(formatting..szValue..",")
							content__ = content__.. "\n"..formatting..(szValue or "nil")..","
						end
					end
				end
				
			end
		end
		return content__
	end
	function pt(...)
		local arg = {...}
		local has = false
		for _, v in pairs(arg) do
			if v and type(v) == "table" then
				has = true
				break
			end
		end
		if not has then
			print("<color=#FF9800>【*】</color>", ...)
		else
			local content__ = ""
			local e = true
			for _, v in pairs(arg) do
				if type(v) ~= "table" then
					content__= content__ .. tostring(v).."\n"
				else
					if e then
						e = false
						content__= content__ .. "<color=#63b12f>【T】=》</color>".._printt(v, limit).."\n"
					else
						content__= content__.._printt(v, limit).."\n"
					end
				end
			end
			print(content__)
		end
	end
	-- 拖动UI显示坐标
	function debugDrag(ui)
		local target = nil
		if type(ui) == "table" then
			target = ui.ui
		else
			target = ui
		end
		target.draggable = true
		target.onDragMove:Add(function ( e )
			print(target.x, target.y)
		end)
	end

-- color --
	function newColorBy0x(r,g,b,a)
		return Color.New(r/0xff, g/0xff, b/0xff, a)
	end
	function newColorBy255(r,g,b,a)
		return Color.New(r/0xff, g/0xff, b/0xff, a)
	end
	--颜色值转换 "#abcedfaa" | "00ff00aa"
	function newColorByString( value )
		local r,g,b,a = "ff", "ff", "ff", "ff"
		if string.find(value, "#") then
			r = string.sub(value,2,3)
			g = string.sub(value,4,5)
			b = string.sub(value,6,7)
			a = string.sub(value,8,9)
		else
			r = string.sub(value,1,2)
			g = string.sub(value,3,4)
			b = string.sub(value,5,6)
			a = string.sub(value,7,8)
		end
		if a=="" then
			a = "ff"
		end
		return newColorBy0x(tonumber("0x"..r), tonumber("0x"..g), tonumber("0x"..b), tonumber("0x"..a))
	end

	function print_r ( t )  
	    local print_r_cache={}
	    local function sub_print_r(t,indent)
	        if (print_r_cache[tostring(t)]) then
	            print(indent.."*"..tostring(t))
	        else
	            print_r_cache[tostring(t)]=true
	            if (type(t)=="table") then
	                for pos,val in pairs(t) do
	                    if (type(val)=="table") then
	                        print(indent.."["..pos.."] => "..tostring(t).." {")
	                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
	                        print(indent..string.rep(" ",string.len(pos)+6).."}")
	                    elseif (type(val)=="string") then
	                        print(indent.."["..pos..'] => "'..val..'"')
	                    else
	                        print(indent.."["..pos.."] => "..tostring(val))
	                    end
	                end
	            else
	                print(indent..tostring(t))
	            end
	        end
	    end
	    if (type(t)=="table") then
	        print(tostring(t).." {")
	        sub_print_r(t,"  ")
	        print("}")
	    else
	        sub_print_r(t,"  ")
	    end
    	print()
	end
	printwk = print_r
	
-- loader --
	-- 加载U3D资源对象 res
	function LoadPrefab( path, callback )
		resMgr:LoadPrefab(path, callback)
	end
	-- 卸掉之前的所有相关ab, isThorough:true包含关系的依赖ab(注意创建的对象会丢掉贴图之类的)
	function UnloadAssetBundle( path, isThorough)
	end
	-- "Assets/IGSoft_Resources/Projects/Effect" 下的 res 特效
	function LoadEffect(res, finishCallback)
		if not res then
			logWarn("LoadEffect error res!"..res)
			return
		end
		local loadCallBack = function ( obj )
			if ToLuaIsNull(obj) then logWarn("LoadEffect error res!"..res) return end
			finishCallback(obj)
		end
		LoadPrefab( StringFormat("Effect/{0}", res), loadCallBack )
	end
	function UnLoadEffect(res, isThorough)
	end
	-- "Assets/Res/Prefabs/Drop" 下的 res 特效
	function LoadDrop(res, finishCallback)
		local loadCallBack = function ( obj )
			if ToLuaIsNull(obj) then logWarn("LoadDrop error res!"..res) return end
			finishCallback(obj)
		end
		LoadPrefab( StringFormat("Prefabs/Drop/{0}", res), loadCallBack )
	end
	function UnLoadDrop(res,isThorough)
	end
	-- "Assets/Res/Prefabs/Player" 下的 res 特效
	function LoadPlayer(res, finishCallback)
		local loadCallBack = function ( obj )
			if ToLuaIsNull(obj) then logWarn("LoadPlayer error res!"..res) return end
			finishCallback(obj)
		end
		LoadPrefab( StringFormat("Prefabs/Player/{0}", res), loadCallBack )
	end
	function UnLoadPlayer(res,isThorough)
	end
	-- "Assets/Res/Prefabs/Weapon" 下的 res 特效
	function LoadWeapon(res, finishCallback)
		local loadCallBack = function ( obj )
			if ToLuaIsNull(obj) then logWarn("LoadWeapon error res!") return end
			finishCallback(obj)
		end
		LoadPrefab( StringFormat("Prefabs/Weapon/{0}", res), loadCallBack )
	end
	function UnLoadWeapon(res,isThorough)
	end
	-- "Assets/Res/Prefabs/Wing" 下的 res 特效
	function LoadWing(res, finishCallback)
		local loadCallBack = function ( obj )
			if ToLuaIsNull(obj) then logWarn("LoadWing error res!"..res) return end
			finishCallback(obj)
		end
		LoadPrefab( StringFormat("Prefabs/Wing/{0}", res), loadCallBack )
	end
	function UnLoadWing(res,isThorough)
	end
	-- "Assets/Res/Prefabs/NPC" 下的 res 特效
	function LoadNPC(res, finishCallback)
		local loadCallBack = function ( obj )
			if ToLuaIsNull(obj) then logWarn("LoadNPC error res!"..res) return end
			finishCallback(obj)
		end
		LoadPrefab( StringFormat("Prefabs/NPC/{0}", res), loadCallBack )
	end
	function UnLoadNPC(res,isThorough)
	end
	-- "Assets/Res/Prefabs/Monster" 下的 res 特效
	function LoadMonster(res, finishCallback)
		local loadCallBack = function ( obj )
			if ToLuaIsNull(obj) then logWarn("LoadMonster error res!"..res) return end
			finishCallback(obj)
		end
		LoadPrefab( StringFormat("Prefabs/Monster/{0}", res), loadCallBack )
	end
	function UnLoadMonster(res,isThorough)
	end
	-- "Assets/Res/Prefabs/Cam" 下的 res 特效
	function LoadCam(res, finishCallback)
		local loadCallBack = function ( obj )
			if ToLuaIsNull(obj) then logWarn("LoadCam error res!"..res) return end
			finishCallback(obj)
		end
		LoadPrefab( StringFormat("Prefabs/Cam/{0}", res), loadCallBack )
	end
	function UnLoadCam(res,isThorough)
	end

	-- "Assets/Res/Prefabs/Drop" 下的模型加载（掉落和采集模型）
	function LoadCollect(res, finishCallback)
		local loadCallBack = function (obj)
			if ToLuaIsNull(obj) then logWarn("LoadCollect error res!" .. res) return end
			finishCallback(obj)
		end
		LoadPrefab(StringFormat("Prefabs/Drop/{0}", res), loadCallBack)
	end
	function UnLoadCollect(res, isThorough)
	end


	function GetGC()
		local cb = collectgarbage("count")
		print("cb ", cb)
	end

	function GetTimeStr(time)
		if not time then return end
		local h=math.floor(time/3600)
		local m=math.floor((time-h*3600)/60)
		local s=time-h*3600-m*60
		local function full(num)
			if num<10 then return '0'..num end
			return tostring(num)
		end
		return full(h)..":"..full(m)..":"..full(s)
	end
	
	-- 移动号段：
	-- 134 135 136 137 138 139 147 150 151 152 157 158 159 172 178 182 183 184 187 188

	-- 联通号段：
	-- 130 131 132 145 155 156 171 175 176 185 186

	-- 电信号段：
	-- 133 149 153 173 177 180 181 189
	-- 虚拟运营商:
	-- 170
	function CheckIsMobilePhoneNum(str)
		return string.match(str,"[1][3,4,5,7,8]%d%d%d%d%d%d%d%d%d") == str
	end

	function CreateRedPoint(parentUI , posX , posY , visible)
		local rtnRedPoint = nil
		if parentUI then
			local redPointGO = UIPackage.CreateObject("Common" , "red_tips")
			redPointGO.name = "red_tips"
			redPointGO:SetXY( posX , posY)
			parentUI:AddChild(redPointGO)
			redPointGO.visible = visible
			rtnRedPoint = redPointGO
		end
		return rtnRedPoint
	end

	-- 打开本地文件（如 log.txt）
	function ReadLocalFile(filename)
		local file
		if filename == nil then
			file = io.stdin
		else
			local err
			file, err = io.open(filename, "rb")
			if file == nil then
				error(("Unable to read '%s': %s"):format(filename, err))
			end
		end
		local data = file:read("*a")
		if filename ~= nil then
			file:close()
		end
		if data == nil then
			error("Failed to read " .. filename)
		end
		return data
	end
	-- 写入本地文件（如 log.txt）
	function WriteLocalFile(filename, data)
	    local file
	    if filename == nil then
	        file = io.stdout
	    else
	        local err
	        file, err = io.open(filename, "wb")
	        if file == nil then
	            error(("Unable to write '%s': %s"):format(filename, err))
	        end
	    end
	    file:write(data)
	    if filename ~= nil then
	        file:close()
	    end
	end
	-- @desc : 写入聊天记录到平台可读写路径
	-- @param : selfId ==>> 主角id, playerId ==>> 要存的玩家的id, tab ==>> string数组
	function WriteChatRecords(selfId, playerId, tab)
		local str = table.concat(tab, "___") or ""
		Util.WriteLocalRecords(tostring(selfId), tostring(playerId), str, "chat_records")
	end

	-- @desc : 读文件反序列化成table
	function ReadChatRecords(selfId, playerId)
		local str = Util.ReadLocalRecords(selfId, playerId, "chat_records")
		local tab = {}
		-- print("read str ==>> ")
		-- print(str)
		if str then
			tab = StringSplit(str, "___")
		end
		--printwk(tab)
		return tab
	end
	--@desc : 分隔符分割数字
	--@example: input ==>> (99999, ',', 3), output ==>> 99,999
	function number_format(num, deperator, indent)
	    local str1 = ""  
	    local str = tostring(num)  
	    local strLen = string.len(str)
	    deperator = deperator or ','
	    deperator = tostring(deperator)
	    indent = indent or 3
	    for i = 1, strLen do  
	        str1 = string.char(string.byte(str, strLen + 1 - i)) .. str1  
	        if math.mod(i, indent) == 0 and strLen - i ~= 0 then
	            str1 = "," .. str1
	        end  
	    end  
	    return str1  
	end  

------------------------------------------------------ game engine ---------------------------------------------------
