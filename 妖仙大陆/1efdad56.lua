local _M = {}
_M.__index = _M


local creater = require "Zeus.UI.FormatUI"
local Util = require'Zeus.Logic.Util'
local ItemModel = require'Zeus.Model.Item'
local IS_SHOW_MIN_MAX = false
local FONT_MIDDLE = 22
local FONT_LARGE = 28
local FONT_SMALL = 20

local TXT_COLOR = 
{
	WHITE = Util.GetQualityColorRGBA(GameUtil.Quality_Default),
	GREEN = Util.GetQualityColorRGBA(GameUtil.Quality_Green),
	BLUE = Util.GetQualityColorRGBA(GameUtil.Quality_Blue),
	PURPLE = Util.GetQualityColorRGBA(GameUtil.Quality_Purple),
	ORANGE = Util.GetQualityColorRGBA(GameUtil.Quality_Orange),
	RED  = Util.GetQualityColorRGBA(GameUtil.Quality_Red),
	YELLOW = 0xffff00ff,
	GRAY = 0x5e5e5eff,
}

local Text = {
	Txt_needLv       = Util.GetText(TextConfig.Type.ITEM,'needLv'),
	Txt_sell         = Util.GetText(TextConfig.Type.ITEM,'sellPrice'),
	Txt_durability   = Util.GetText(TextConfig.Type.ITEM,'durability'),
	Txt_score        = Util.GetText(TextConfig.Type.ITEM,'score'),
	Txt_attrRandom   = Util.GetText(TextConfig.Type.ITEM,'attrRandom'),
	Txt_magic        = Util.GetText(TextConfig.Type.ITEM,'attrMagic'),
	Txt_gemSlot      = Util.GetText(TextConfig.Type.ITEM,'gemSlot'),
	Txt_emptySlot    = Util.GetText(TextConfig.Type.ITEM,'emptySlot'),
	Txt_inlay        = Util.GetText(TextConfig.Type.ITEM,'inlay'),
	Txt_or           = Util.GetText(TextConfig.Type.ITEM,'or'),
	Txt_cantSell     = Util.GetText(TextConfig.Type.ITEM,'cantSell'),
	Txt_maxLimit     = Util.GetText(TextConfig.Type.ITEM,'maxLimit'),
	Txt_unidentified = Util.GetText(TextConfig.Type.ITEM,'unidentified'),
	Txt_levelDesc    = Util.GetText(TextConfig.Type.ITEM,'levelDesc'),
	Txt_upLevelDesc  = Util.GetText(TextConfig.Type.ITEM,'upLevelDesc'),
	Txt_proDesc			 = Util.GetText(TextConfig.Type.ITEM,'proDesc'),
	Txt_maxCount     = Util.GetText(TextConfig.Type.ITEM,'maxCount'),
	Txt_count        = Util.GetText(TextConfig.Type.ITEM,'count'),
	Txt_useLevel     = Util.GetText(TextConfig.Type.ITEM,'useLevel'),
	Txt_magicDes		 = Util.GetText(TextConfig.Type.ITEM,'attrMagic'),
	Txt_unkownScore  = Util.GetText(TextConfig.Type.ITEM,'unkownScore'),
	Txt_identify1    = Util.GetText(TextConfig.Type.ITEM,'identify1'),
	Txt_identify2    = Util.GetText(TextConfig.Type.ITEM,'identify2'),
	Txt_amuletSpace  = Util.GetText(TextConfig.Type.ITEM,'amuletSpace'),
	Txt_both_hands	 = Util.GetText(TextConfig.Type.ITEM,'both_hands'),
	Txt_bind0				 = Util.GetText(TextConfig.Type.ITEM,'noBind'),
	Txt_bind1				 = Util.GetText(TextConfig.Type.ITEM,'binded'),
	Txt_bind2				 = Util.GetText(TextConfig.Type.ITEM,'equipBind'),
	Txt_bind3				 = Util.GetText(TextConfig.Type.ITEM,'pickBind'),
	Txt_bind4				 = Util.GetText(TextConfig.Type.ITEM,'buyBind'),
	Text_magicEffect = Util.GetText(TextConfig.Type.ITEM,'enchantedTitle1'),
	noRefine 				 = Util.GetText(TextConfig.Type.ITEM,'noRefine'),
	advanceSuffix    = Util.GetText(TextConfig.Type.ITEM,'advanceSuffix'),
}


local function DescFormat(str,numColor,...)
	local r = {'{A}','{B}','{C}','{D}','{E}','{F}','{G}','{H}','{I}','{J}','{K}','{L}'}
	local params = {...}
	for i=1,#params do
		local subText = params[i]
		if numColor then
			subText = string.format('<color=#%s>%s</color>',numColor,subText)
		end
		str = string.gsub(str,r[i],subText)
	end
	return str
end

local function GetAttrName(id)
	local attr = GlobalHooks.DB.Find('Attribute',id)
	return attr.attName
end

local function GetAttrDesc(attr,numColor)
	local attrdata = GlobalHooks.DB.Find('Attribute',attr.id)


	
	if attrdata.attParamCount == 1 then
		local v = (attrdata.isFormat == 1 and attr.value / 100) or attr.value
		return DescFormat(attrdata.attDesc,numColor,v or 0)
	elseif attrdata.attParamCount > 1 then
		local params = {}
		for i=1,attrdata.attParamCount do
			
			if i == 1 and string.find(attrdata.attKey,'Skill') then
				print('attrdata.attKey',attrdata.attKey,attr.param1)
				local sd = GlobalHooks.DB.Find('SkillData',attr.param1)
				if sd then
					table.insert(params,sd.SkillName)
				else
					table.insert(params,attr['param'..i] or 0)
				end
			else
				local v = (attrdata.isFormat == 1 and attr['param'..i] / 100) or attr['param'..i]
				
				table.insert(params,v or 0)
			end
		end
		return DescFormat(attrdata.attDesc,numColor,unpack(params))
	else
		return attrdata.attDesc
	end
end

local txts = {'我','是','不','花','华','天','一','二','伞','三','四','五'}

local function RandomTxt(length)
	local txt = ''
	for j=1,length do
		local index = math.random(1,#txts)
		txt = txt..txts[index]
	end	
	return txt
end


local function GetUITemplate(str_type, con_w,start_x)
	if not start_x then
		start_x = 25
	end
	if str_type == 'mini_normal_begin' then
		return {
			X = start_x,
			{		
				direction = 'h',
				{id='name',HZLabel.CreateLabel,FontSize=FONT_MIDDLE},
				{id='secondType',HZLabel.CreateLabel,FontSize=FONT_SMALL,Color=TXT_COLOR.WHITE,TextAnchor=TextAnchor.R_T,X=con_w},			
			},
			{
				direction='h',
				{id="useLevel",HZLabel.CreateLabel,FontSize=FONT_MIDDLE,Color=TXT_COLOR.WHITE},
				{id="bind",HZLabel.CreateLabel,FontSize=FONT_SMALL,Color=TXT_COLOR.WHITE,TextAnchor=TextAnchor.R_T,X=con_w},
			},
		}
	elseif str_type == 'mini_equip_begin' then
		return {
			X = start_x,
			{
				direction = 'h',
				{id='name',HZLabel.CreateLabel,FontSize=FONT_MIDDLE},
				{id='secondType',HZLabel.CreateLabel,FontSize=FONT_SMALL,Color=TXT_COLOR.WHITE,TextAnchor=TextAnchor.R_T,X=con_w},			
			},
			{
				direction='h',
				{id="pro",HZLabel.CreateLabel,FontSize=FONT_MIDDLE,Color=TXT_COLOR.WHITE},
				{id="bind",HZLabel.CreateLabel,FontSize=FONT_SMALL,Color=TXT_COLOR.WHITE,TextAnchor=TextAnchor.R_T,X=con_w},
			},
			{
				direction='h',
				{id="level",HZLabel.CreateLabel,FontSize=FONT_MIDDLE,Color=TXT_COLOR.WHITE},
				{id="score",HZLabel.CreateLabel,FontSize=FONT_SMALL,Color=0xef880eff,TextAnchor=TextAnchor.R_T,X=con_w,Y=3},
			},
			
			{id="amuletSpace",HZLabel.CreateLabel,FontSize=FONT_MIDDLE,Color=TXT_COLOR.WHITE},
		}
	elseif str_type == 'normal_begin_template' then
		return {
			X=start_x,
			{id="secondType",HZLabel.CreateLabel,FontSize=FONT_SMALL,Color=TXT_COLOR.WHITE,TextAnchor=TextAnchor.R_T,X=con_w},
			{
				direction='h',
				{id="num",HZLabel.CreateLabel,FontSize=FONT_MIDDLE,Color=TXT_COLOR.WHITE,Y=-5},
				{id="bind",HZLabel.CreateLabel,FontSize=FONT_SMALL,Color=TXT_COLOR.WHITE,TextAnchor=TextAnchor.R_T,X=con_w},
			},
			{id="maxNum",HZLabel.CreateLabel,FontSize=FONT_MIDDLE,Color=TXT_COLOR.WHITE},
			{id="useLevel",HZLabel.CreateLabel,FontSize=FONT_MIDDLE,Color=TXT_COLOR.WHITE},
		}
	elseif str_type == 'normal_content_template' then
		return {
			X=start_x,
			{HZImageBox.New,Img='#static_n/static_pic/static001.xml|static001|28',Y=10,padding=10,W=con_w-start_x,UIStyle=LayoutStyle.IMAGE_STYLE_H_012,ClipSize=15},
			{id='desc1',HZTextBoxHtml.New,ContentW=con_w,padding=10},
			{id='desc2',HZTextBoxHtml.New,ContentW=con_w,padding=10},
			{id='desc3',HZTextBoxHtml.New,ContentW=con_w},
		}
	elseif str_type == 'equip_begin_template' then
		return {
			X=start_x,
			{id="secondType",HZLabel.CreateLabel,FontSize=FONT_SMALL,Color=TXT_COLOR.WHITE,TextAnchor=TextAnchor.R_T,X=con_w},
			{
				direction='h',
				{id="proLimit",HZLabel.CreateLabel,FontSize=FONT_MIDDLE,Color=TXT_COLOR.WHITE,Y=-10},
				{id="bind",HZLabel.CreateLabel,FontSize=FONT_SMALL,Color=TXT_COLOR.WHITE,TextAnchor=TextAnchor.R_T,X=con_w},
			},
			{	
				
				direction='h',
				{id="level",HZLabel.CreateLabel,FontSize=FONT_MIDDLE,Color=TXT_COLOR.WHITE},
				{id="score",HZLabel.CreateLabel,FontSize=FONT_SMALL,Color=0xef880eff,TextAnchor=TextAnchor.R_T,X=con_w,Y=3},
			},
			{id="amuletSpace",HZLabel.CreateLabel,FontSize=FONT_MIDDLE,Color=TXT_COLOR.WHITE},
		}
	elseif str_type == 'equip_unident_content_template' then
		return {
			X = start_x,
			{HZImageBox.New,Img='#static_n/static_pic/static001.xml|static001|28',Y=10,padding=10,W=con_w,UIStyle=LayoutStyle.IMAGE_STYLE_H_012,ClipSize=15},
			{
				id='mainAttrContent',
				{
					id='mainAttrArray',
					direction='h',
					{sub_id='img',HZImageBox.New,Img='#static_n/static_pic/static001.xml|static001|20',Y=9,padding=8},
					{sub_id='attr',HZLabel.CreateLabel,FontSize=FONT_MIDDLE,Color=TXT_COLOR.WHITE},
				},
				{HZImageBox.New,Img='#static_n/static_pic/static001.xml|static001|28',padding=10,W=con_w,UIStyle=LayoutStyle.IMAGE_STYLE_H_012,ClipSize=15},
			},
			{id='identifyDesc',HZTextBoxHtml.New,ContentW=con_w,padding=20},
			{HZImageBox.New,Img='#static_n/static_pic/static001.xml|static001|28',padding=10,W=con_w,UIStyle=LayoutStyle.IMAGE_STYLE_H_012,ClipSize=15},
			{id='identifyCostDesc',HZTextBoxHtml.New,ContentW=con_w,padding=20},
		}
	elseif str_type == 'equip_unident_content_mini_template' then
		return {
			X = start_x,
			{HZImageBox.New,Img='#static_n/static_pic/static001.xml|static001|28',Y=10,padding=10,W=con_w,UIStyle=LayoutStyle.IMAGE_STYLE_H_012,ClipSize=15},
			{
				id='mainAttrContent',
				{
					id='mainAttrArray',
					direction='h',
					padding=10,
					{sub_id='img',HZImageBox.New,Img='#static_n/static_pic/static001.xml|static001|20',Y=9,padding=8},
					{sub_id='attr',HZLabel.CreateLabel,FontSize=FONT_MIDDLE,Color=TXT_COLOR.WHITE},
				},
			},
		}		
	elseif str_type == 'equip_content_template' then
		return {
			X = start_x,
			{
				id='mainAttrContent',
				{
					{Y=10,HZImageBox.New,Img='#static_n/static_pic/static001.xml|static001|28',padding=10,W=con_w,UIStyle=LayoutStyle.IMAGE_STYLE_H_012,ClipSize=15},
					{
						direction='h',
						{				
							{
								
								id='mainAttrArray',
								direction='h',
								{sub_id='img',HZImageBox.New,Img='#static_n/static_pic/static001.xml|static001|20',Y=9,padding=8},
								{sub_id='attr',HZLabel.CreateLabel,FontSize=FONT_MIDDLE,Color=TXT_COLOR.WHITE},
							},
							padding=15,
						},
						{
							{
								id='mainAttrAttrAppendArray',
								direction='h',
								{sub_id='attr',HZLabel.CreateLabel,FontSize=FONT_MIDDLE,Color=TXT_COLOR.GREEN},
							},
						},
					},
				},
			},
			{
				
				id='randomContent',
				{
					
					id='randomContent_attr',
					{Y=10,HZImageBox.New,Img='#static_n/static_pic/static001.xml|static001|28',padding=10,W=con_w,UIStyle=LayoutStyle.IMAGE_STYLE_H_012,ClipSize=15},
					{
						id='randomAttrs',
						direction='h',
						{sub_id='img',HZImageBox.New,Img='#static_n/static_pic/static001.xml|static001|20',Y=9,padding=8},
						{sub_id='attr',HZLabel.CreateLabel,FontSize=FONT_MIDDLE,Color=TXT_COLOR.WHITE},
					},
				},
			},
			
			{
				id='gemContent',
				{
					{Y=10,HZImageBox.New,Img='#static_n/static_pic/static001.xml|static001|28',padding=10,W=con_w,UIStyle=LayoutStyle.IMAGE_STYLE_H_012,ClipSize=15},
					{
						direction='h',
						id='gemAttrs',
						
						{sub_id='img',HZImageBox.New,padding=8,Y=4,W=25,H=25},
						{sub_id='attr',HZLabel.CreateLabel,FontSize=FONT_MIDDLE},
					},
				},
			},
			{
				id='magicContent',
				{
					{Y=10,HZImageBox.New,Img='#static_n/static_pic/static001.xml|static001|28',padding=10,W=con_w,UIStyle=LayoutStyle.IMAGE_STYLE_H_012,ClipSize=15},
					{HZImageBox.New,Img='#static_n/static_pic/static001.xml|static001|79',padding=10,W=con_w,UIStyle=LayoutStyle.IMAGE_STYLE_H_012,ClipSize=15},
					{id='magicTitle',HZLabel.CreateLabel,FontSize=FONT_MIDDLE,Color=0xFFC98AFF,TextAnchor=TextAnchor.C_C,Y=26,W=con_w,H=30,padding=10},					
					{
						id='magicAtts',
						direction='h',
						
						{sub_id='img',HZImageBox.New,Img='#static_n/static_pic/static001.xml|static001|20',Y=9,padding=8},
						{sub_id='attr',HZLabel.CreateLabel,FontSize=FONT_MIDDLE,Color=TXT_COLOR.WHITE},
					},
				}
			},
			{
				id='desc',
				{HZImageBox.New,Img='#static_n/static_pic/static001.xml|static001|28',padding=10,W=con_w,UIStyle=LayoutStyle.IMAGE_STYLE_H_012,ClipSize=15},
				{id='desc1',HZTextBoxHtml.New,ContentW=con_w + 8,padding=20},
			},

		}
	end
end


local function CheckShowBindType(data)
	if not data.bindType or data.bindType < 0 then
		return false
	elseif data.id and data.id ~= '' then
		return true
	elseif data.bindType and data.bindTypeChanged then
		return true
	else
		local ele = GlobalHooks.DB.Find('ItemIdConfig',data.itemSecondType)
		if not ele or ele.ShowBind == 1 then
			return true
		else
			return false
		end
	end
end

local function normal_begin(content_width,data,num)
	
	
	
	
	
	local tempData = {}
	tempData.secondType    = Util.GetItemSecondTypeTxt(data.itemSecondType)
	if num > 0 then
		tempData.num   = Text.Txt_count..num 
	end

	if CheckShowBindType(data) then
		tempData.bind = Text['Txt_bind'..(data.bindType or data.static.BindType)]
	end

	tempData.maxNum = Text.Txt_maxCount..data.static.GroupCount

	local self_lv = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.LEVEL)
	

	local level = data.static.LevelReq
	

	local attr_lv = {}
	attr_lv.Text = string.format(Text.Txt_useLevel,level)
	if self_lv < level then
		attr_lv.Color = TXT_COLOR.RED
	end	

	tempData.useLevel = attr_lv

	
	local comp = creater.create_template(GetUITemplate('normal_begin_template',content_width),tempData)
	return comp
end

local function normal_content(content_width,data,startx)
	local tempData = {}
	tempData.desc1 = "<f size='22' color='ffe7e5d1'>"..data.static.Desc..'</f>'
	tempData.desc2 = "<f size='22' color='ffe7e5d1'>"..data.static.Tips..'</f>'
	tempData.desc3 = "<f size='22' color='ffe7e5d1'>"..data.static.Ways..'</f>'
	
	local comp = creater.create_template(GetUITemplate('normal_content_template',content_width,startx),tempData)
	return comp
end

local function mini_normal_begin(content_width,data,start_x)
	local tempData = {}
	local c = Util.GetQualityColorRGBA(data.static.Qcolor)		
	local data_name = {Text=data.static.Name,Color=c}
	
	tempData.name = data_name 
	tempData.secondType    = Util.GetItemSecondTypeTxt(data.itemSecondType)
	if CheckShowBindType(data) then
		tempData.bind = Text['Txt_bind'..(data.bindType or data.static.BindType)]
	end

	local self_lv = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.LEVEL)
	

	local level = data.static.LevelReq
	

	local attr_lv = {}
	attr_lv.Text = string.format(Text.Txt_useLevel,level)
	if self_lv < level then
		attr_lv.Color = TXT_COLOR.RED
	end	

	tempData.useLevel = attr_lv

	local comp = creater.create_template(GetUITemplate('mini_normal_begin',content_width,start_x or 10),tempData)
	return comp	
end

local function mini_equip_begin(content_width,data,start_x)
	local tempData = {}
	local c = Util.GetQualityColorRGBA(data.static.Qcolor)
	local data_name = {Text=data.static.Name,Color=c}

	local enLevel = data.equip and data.equip.enLevel or 0
 	if enLevel > 0 then
		data_name.Text = string.format('%s  (+%d)', data_name.Text,enLevel)
	end

	tempData.name = data_name 

	tempData.secondType    = Util.GetItemSecondTypeTxt(data.itemSecondType)

	if data.static.isBothHand == 1 then
		tempData.secondType = Text.Txt_both_hands
	end

	tempData.bind = Text['Txt_bind'..(data.bindType or data.static.BindType)]
	local userdata = DataMgr.Instance.UserData
	local self_lv = userdata:GetAttribute(UserData.NotiFyStatus.LEVEL)
	local self_uplv = userdata:GetAttribute(UserData.NotiFyStatus.UPLEVEL)
	local self_pro = userdata.Pro
	local level = data.static.LevelReq
	local uplevel = data.static.UpReq

	local attr_pro = {Text = Text.Txt_proDesc..data.static.Pro}
	if data.equip.pro ~= self_pro then
		attr_pro.Color = TXT_COLOR.RED
	end
	tempData.pro = attr_pro

	local attr_lv = {}

	if level == 0 and uplevel > 0 then
		
		attr_lv.SupportRichtext = true

		local ret = unpack(GlobalHooks.DB.Find('UpLevelExp',{UpLevel=uplevel,Pro=data.static.Pro}))
		local rgba = Util.GetQualityColorRGBAStr(ret.Qcolor)

		if self_uplv < uplevel then
			attr_lv.Color = TXT_COLOR.RED
			attr_lv.Text = Text.Txt_upLevelDesc..ret.UpName
		else
			attr_lv.Text = string.format('%s<color=#%s>%s</color>',Text.Txt_upLevelDesc,rgba,ret.UpName)
		end	
	else
		attr_lv.Text = Text.Txt_levelDesc..level
		if self_lv < level then
			attr_lv.Color = TXT_COLOR.RED
		end		
	end

	tempData.level = attr_lv

	local score = (data.equip.isIdentfied ~=1 and Text.Txt_unkownScore) or data.equip.score
	if type(score) == 'number' and score <= 0 then
		score = Text.Txt_unkownScore
	end
	tempData.score = Text.Txt_score..score
	if data.static.Space > 0 then
		tempData.amuletSpace = Text.Txt_amuletSpace..data.static.Space
	end

	local comp = creater.create_template(GetUITemplate('mini_equip_begin',content_width,start_x or 10),tempData)
	return comp	
end

local function equip_begin(content_width,data)
	
	
	
	
	
	local tempData = {}
	tempData.secondType    = Util.GetItemSecondTypeTxt(data.itemSecondType)
	if data.static.isBothHand == 1 then
		tempData.secondType = Text.Txt_both_hands
	end
	
	local userdata = DataMgr.Instance.UserData
	local self_lv = userdata:GetAttribute(UserData.NotiFyStatus.LEVEL)
	local self_uplv = userdata:GetAttribute(UserData.NotiFyStatus.UPLEVEL)
	local self_pro = userdata.Pro
	local level = data.static.LevelReq
	local uplevel = data.static.UpReq
	local pro = data.equip.pro
	local bind = false
	local attr_lv = {}

	if level == 0 and uplevel > 0 then
		
		attr_lv.SupportRichtext = true
		local ret = unpack(GlobalHooks.DB.Find('UpLevelExp',{UpLevel=uplevel}))
		local rgba = Util.GetQualityColorRGBAStr(ret.Qcolor)

		if self_uplv < uplevel then
			attr_lv.Color = TXT_COLOR.RED
			attr_lv.Text = Text.Txt_upLevelDesc..ret.UpName
		else
			attr_lv.Text = string.format('%s<color=#%s>%s</color>',Text.Txt_upLevelDesc,rgba,ret.UpName)
		end	
	else
		attr_lv.Text = Text.Txt_levelDesc..level
		if self_lv < level then
			attr_lv.Color = TXT_COLOR.RED
		end		
	end

	tempData.level = attr_lv

	local ele = GlobalHooks.DB.Find('Character',pro)
	local attr_pro = {Text = Text.Txt_proDesc..ele.ProName}
	if pro ~= 0 and pro ~= self_pro then
		attr_pro.Color = TXT_COLOR.RED
	end

	local score = (data.equip.isIdentfied ~=1 and Text.Txt_unkownScore) or data.equip.score
	if type(score) == 'number' and score <= 0 then
		score = Text.Txt_unkownScore
	end
	tempData.proLimit = attr_pro
	tempData.bind = Text['Txt_bind'..(data.bindType or data.static.BindType)]
	tempData.score = Text.Txt_score..score

	if data.static.Space > 0 then
		tempData.amuletSpace = Text.Txt_amuletSpace..data.static.Space
	end

	local comp = creater.create_template(GetUITemplate('equip_begin_template',content_width),tempData)

	return comp
end

local function equip_unidentify_content_mini(content_width,equip_data,startx)
	local tempData = {}
	if not startx then
		startx = 0
	end
	local format1 = '%s:%d'
	local format2 = '%s:%d-%d'
	for _,attr in ipairs(equip_data.baseAtts or {}) do
		tempData.mainAttrArray = tempData.mainAttrArray or {}
		if attr.value >= 0 then
			table.insert(tempData.mainAttrArray,{attr=string.format(format1,GetAttrName(attr.id),attr.value)})
		else
			table.insert(tempData.mainAttrArray,{attr=string.format(format2,GetAttrName(attr.id),attr.minValue,attr.maxValue)})
		end
	end
	tempData.mainAttrContent = true 	
	return creater.create_template(
		GetUITemplate('equip_unident_content_mini_template',content_width,startx),tempData)
end

local function equip_unidentify_content(self,content_width,equip_data,startx)
	local tempData = {}
	if not startx then
		startx = 0
	end
	local format1 = '%s:%d'
	local format2 = '%s:%d-%d'
	for _,attr in ipairs(equip_data.baseAtts or {}) do
		tempData.mainAttrArray = tempData.mainAttrArray or {}
		if attr.value >= 0 then
			table.insert(tempData.mainAttrArray,{attr=string.format(format1,GetAttrName(attr.id),attr.value)})
		else
			table.insert(tempData.mainAttrArray,{attr=string.format(format2,GetAttrName(attr.id),attr.minValue,attr.maxValue)})
		end
	end
	tempData.mainAttrContent = true 
	local txt_num
	if equip_data.noIdentifyInfo.minRandomAttrNum == equip_data.noIdentifyInfo.maxRandomAttrNum then
		txt_num = string.format("<f size='22' color='ff5bc61a'>%d</f>",equip_data.noIdentifyInfo.maxRandomAttrNum)
	else
		txt_num = string.format("<f size='22' color='ff5bc61a'>%d-%d</f>",
										equip_data.noIdentifyInfo.minRandomAttrNum,equip_data.noIdentifyInfo.maxRandomAttrNum)
	end

	
	if equip_data.noIdentifyInfo.identifyRoll then
		local scr_code = equip_data.noIdentifyInfo.identifyRoll.code
		local scr_num = equip_data.noIdentifyInfo.identifyRoll.num
		local ele = GlobalHooks.DB.Find('Items',scr_code)
		local c = Util.GetQualityColorARGB(ele.Qcolor)
		local name_txt = string.format("<f color='%x'>%s</f>",c,ele.Name)

		local txt = string.format(Text.Txt_identify1,name_txt,txt_num)

		tempData.identifyDesc = txt

		local bag_data = DataMgr.Instance.UserData.RoleBag

		if self.unidentify_filter then
  		bag_data:RemoveFilter(self.unidentify_filter)
  	end

		self.unidentify_filter = ItemPack.FilterInfo.New()
		self.unidentify_filter.MergerSameTemplateID = true
		self.unidentify_filter.CheckHandle = function (item)
			return item.TemplateId == scr_code
		end

		local function GetIdentifyCostText()
			local vItem = bag_data:MergerTemplateItem(scr_code)
			local cur_num = (vItem and vItem.Num) or 0			
			local desc_name
			if cur_num >= scr_num then
				desc_name = string.format('%d/%d'..name_txt,cur_num,scr_num)
			else
				desc_name = string.format("<f color='fff43a1c'>%d</f>/%d"..name_txt,cur_num,scr_num)
			end
			return string.format(Text.Txt_identify2,desc_name)		
		end

		self.unidentify_filter.NofityCB = function ()
			if self.comps2 then
				local n = XmdsUISystem.FindChildByName(self.comps2.node, 'identifyCostDesc', true)
				if n and not n.IsDispose then
					n.XmlText = GetIdentifyCostText()
				end
			end
		end

		bag_data:AddFilter(self.unidentify_filter)

		
		
		
		
		
		
		
		
		
		tempData.identifyCostDesc = GetIdentifyCostText()
	end
	return creater.create_template(GetUITemplate('equip_unident_content_template',content_width,startx),tempData)
end


local function get_attr_color(min,max,value)
	local A = value - min
	local B = max - min
	local X = tonumber((A/B + 0.005)*100)
  if X < 33 then
  	return TXT_COLOR.GREEN
  elseif X < 66 then
  	return TXT_COLOR.BLUE
  elseif X < 90 then
  	return TXT_COLOR.PURPLE
  else
  	return TXT_COLOR.ORANGE
  end
end


local function get_gem_icon(code)
	return "static_n/item/"..code..".png";
end

local function equip_content(content_width,data,startx)	
	local equip_data = data.equip
	local tempData = {}
	if not startx then
		startx = 0
	end
	local format1 = '%s:%s'
	local format2 = '%s:%s-%s'
	local format3 = '(+%s)'

	local enProp
	local enLevel = data.equip.enLevel

	for _,attr in ipairs(equip_data.baseAtts or {}) do
		tempData.mainAttrArray = tempData.mainAttrArray or {}

		local attrdata = GlobalHooks.DB.Find('Attribute',attr.id)

		local v = (attrdata.isFormat == 1 and attr.value / 100) or attr.value
		local append = (attrdata.isFormat == 1 and '%') or ''
		if attr.value >= 0 then
			table.insert(tempData.mainAttrArray,{attr=string.format(format1,attrdata.attName,v..append)})
		else
			local min = (attrdata.isFormat == 1 and attr.minValue / 100) or attr.minValue
			local max = (attrdata.isFormat == 1 and attr.maxValue / 100) or attr.maxValue
			table.insert(tempData.mainAttrArray,{attr=string.format(format2,attrdata.attName,min..append,max..append)})
		end
		
		local addValue = ItemModel.GetStrengthenValue(enLevel,attr)
		if addValue and addValue > 0 then
			tempData.mainAttrAttrAppendArray = tempData.mainAttrAttrAppendArray or {}
			table.insert(tempData.mainAttrAttrAppendArray,{attr=string.format(format3,addValue..append)})
		end
	end

	tempData.mainAttrContent = equip_data.baseAtts and #equip_data.baseAtts > 0

	tempData.randomAttrs = {}
	tempData.randomContent = equip_data.randomAtts and #equip_data.randomAtts > 0
	tempData.randomContent_attr = tempData.randomContent
	
	for _,attr in ipairs(equip_data.randomAtts or {}) do
		local refineLv = attr.param1
		local qColor = attr.param2
		local c
		if attr.param2 then
			c = Util.GetQualityColorRGBA(attr.param2)
		elseif attr.id == 0 then
			c = TXT_COLOR.GRAY
		else
			c = Util.GetQualityColorRGBA(qColor)
		end
		local txt
		if attr.id ~= 0 then
			local rgba = Util.GetQualityColorRGBAStr(GameUtil.Quality_Default)
			txt = string.format('%s <color=#%s>(%d%s)</color>',GetAttrDesc(attr),rgba,refineLv,Text.advanceSuffix)
		else
			txt = Text.noRefine
		end
		
		table.insert(tempData.randomAttrs,
			{attr={Text=txt,Color=c}})
	end

	local jewelAttrs = {}
	for _,v in ipairs(equip_data.jewelAtts or {}) do
		jewelAttrs[v.index] = v
	end
	
	for i=1,data.static.SocksNum do
		tempData.gemAttrs = tempData.gemAttrs or {}
		local jewelAttr = jewelAttrs[i]
		if jewelAttr then
			local jewel_txt = '%s:%s'
			jewel_txt = string.format(jewel_txt,jewelAttr.gem.name,GetAttrDesc(jewelAttr))
			local jewel_data = {
				img=get_gem_icon(jewelAttr.gem.icon),
				attr={Text=jewel_txt,Color=Util.GetQualityColorRGBA(jewelAttr.gem.qColor)}
			}
			table.insert(tempData.gemAttrs,jewel_data)
		else
			table.insert(tempData.gemAttrs,{img='#dynamic_n/dynamic_new/character/character.xml|character|25',
																		  attr={Text=Text.Txt_emptySlot,Color=TXT_COLOR.GRAY}})
		end
	end

	tempData.gemContent = tempData.gemAttrs and #tempData.gemAttrs > 0


	
	for _,attr in ipairs(equip_data.magicAtts or {}) do
		local min = attr.minValue
		local max = attr.maxValue
		local value = attr.value
		tempData.magicAtts = tempData.magicAtts or {}
		table.insert(tempData.magicAtts,{attr={Text=GetAttrDesc(attr),Color=get_attr_color(min,max,value)}})
	end
	tempData.magicContent = equip_data.magicAtts and #equip_data.magicAtts > 0
	tempData.magicTitle = Text.Text_magicEffect
	
	
	
	

	return creater.create_template(GetUITemplate('equip_content_template',content_width,startx),tempData)
end


local function HideMinMaxRandom(self, node)
	for _,v in pairs(self.random_save) do
		v.node.Text = v.text
	end
	IS_SHOW_MIN_MAX = false
end

function _M.SetCurNum(self, num)
	local n = XmdsUISystem.FindChildByName(self.comps1.node, 'num', true)
	if n then
		n.Text = Text.Txt_count..num
	end
end

local function ShowMinMaxRandom(self,equip_data, node)
	local n = XmdsUISystem.FindChildByName(node, 'randomContent_attr', true)
	local pt = 1
	IS_SHOW_MIN_MAX = true
	self.random_save = {}
	Util.ForEachChild(n,function (sender)
		
		if sender.Name == 'randomAttrs' then
			local attr = equip_data.randomAtts[pt]
			local min = attr.minValue
			local max = attr.maxValue
			
			local attr_node = XmdsUISystem.FindChildByName(sender, 'attr', false)
			if attr_node then
				table.insert(self.random_save,{node=attr_node,text=attr_node.Text})
				attr_node.SupportRichtext = true
				attr_node.Text = string.format('%s <color=#5e5e5eff>(%d~%d)</color>',attr_node.Text,min,max)
			end
			pt = pt + 1
		end
	end)
end

local function Init(ret, root, data ,score_compare)
	if not data then return end
  ret.data = data

  ret.root = root
  root.event_disposed = function (sender)
  	
  	if ret.filter then
  		DataMgr.Instance.UserData.RoleBag:RemoveFilter(ret.filter)
  	end
  	if ret.unidentify_filter then
  		DataMgr.Instance.UserData.RoleBag:RemoveFilter(ret.unidentify_filter)
  	end
  end
  
	local helper = require'Zeus.Logic.Helper'
	local c = Util.GetQualityColorRGBA(data.static.Qcolor)
	local lb_name = root:FindChildByEditName('lb_GearName',true)

	lb_name.Text = data.static.Name

 	lb_name.FontColorRGBA = c
 	local comps1,comps2

 	local pan = root:FindChildByEditName('sp_GearInfo',true)
 	local tbt_attribute = root:FindChildByEditName('tbt_attribute',true)
 	local ib_up = root:FindChildByEditName("ib_up",true)
	local ib_down = root:FindChildByEditName("ib_down",true)
	ib_up.Visible = false
	ib_down.Visible = false

 	tbt_attribute.Visible = false
 	local secondType = data.itemSecondType
 	
 	local function SetScoreArrow(compare_value)
 		
 		if not compare_value then return end
 		if compare_value == 0 then
 			
 			local cmp = ItemModel.GetLocalCompareDetail(secondType)
 			if not cmp then
 				compare_value = 1
 			elseif cmp.equip.isIdentfied == 1 then 				 		
 				if cmp.equip.score < data.equip.score then
 					compare_value = 1
 				elseif cmp.equip.score > data.equip.score then
 					compare_value = -1
 				end
	 		end
 		end
 		local n = XmdsUISystem.FindChildByName(comps1.node, 'score', true)
 		if compare_value > 0 then
 			
 			ib_up.Visible = true
	 		n.X = n.X - ib_up.Width
 		elseif compare_value < 0 then
 			
 			ib_down.Visible = true
 			n.X = n.X - ib_down.Width
 		end
 	end

 	if data.equip then
 		local pro = data.equip.pro
 		comps1 = equip_begin(ret.content_width,data)
 		if data.equip.isIdentfied == 1 then			
 			if score_compare then
	 			SetScoreArrow(score_compare)		
	 		end

 			local enLevel = data.equip.enLevel
 		 	if enLevel > 0 then
 				lb_name.Text = string.format('%s  (+%d)', lb_name.Text,enLevel)
 			end

 			comps2 = equip_content(ret.content_width,data)

 			
	 		
	 		
	 		
 			
 			
 			
 			
 			
	 		
	 		
	 		
	 		
	 		
	 		
	 		
 		else
 			comps2 = equip_unidentify_content(ret,ret.content_width,data.equip)
 		end
 	else
 		local has_num = 0
 		
	 		local rg = DataMgr.Instance.UserData.RoleBag
	 		if ret.filter then
	 			rg:RemoveFilter(ret.filter)
	 		end
	 		ret.filter = ItemPack.FilterInfo.New()
			ret.filter.CheckHandle = function (item)
				return item.TemplateId == data.static.Code
			end

			ret.filter.NofityCB = function (pack,status,index)
				local vItem = rg:MergerTemplateItem(data.static.Code)
				ret:SetCurNum((vItem and vItem.Num) or 0)
			end

			local vItem1 = rg:MergerTemplateItem(data.static.Code)
			has_num = (vItem1 and vItem1.Num) or has_num
		
		comps1 = normal_begin(ret.content_width,data, has_num)
		
		local txt = string.format("<f size='22' color='ff5bc61a'>%s</f>",data.static.Desc)
		comps2 = normal_content(ret.content_width,data,0)
 	end


 	ret.comps1 = comps1
	ret.comps2 = comps2
	if ret.filter then
		DataMgr.Instance.UserData.RoleBag:AddFilter(ret.filter)
	end
	local upArrow = root:FindChildByEditName("ib_arrorup",true)
	local downArrow = root:FindChildByEditName("ib_arrordown",true)
 	local function CheckScollPan()
		local check_point = 2
		upArrow.Visible = true
		downArrow.Visible = true
		if pan.Scrollable.Container.Y > -check_point then 
			upArrow.Visible = false
		end
		local h = pan.Scrollable.Container.Height + pan.Scrollable.Container.Y
		if h <= pan.Scrollable.ScrollRect2D.height + check_point then 
			downArrow.Visible = false
		end 			
 	end
 

 
 	pan.Scrollable.event_Scrolled = function (sender,e)
 		CheckScollPan()
 	end

  comps1.node.Y = lb_name.Y + lb_name.Height + comps1.node.Y - 15
	root:AddChild(comps1.node)
	
	pan.ContainerPanel:AddChild(comps2.node)
	local off_pan_y = pan.Y
	pan.Y = comps1.node.Y + comps1.node.Height
	off_pan_y = pan.Y - off_pan_y
	if ret.btns then
 		pan.Height = ret.btns[1].Y - pan.Y - 10
 	else
 		pan.Height = pan.Height - off_pan_y
 	end

	local fa = DelayAction.New()
  fa.Duration = 0.2
  fa.ActionFinishCallBack = function (sender)
  	pan.Scrollable:LookAt(Vector2.New(0,0),false)
 	end

 	pan:AddAction(fa)
 	
	upArrow.Visible = false
	downArrow.Visible = comps2.node.Height > pan.Height
	tbt_attribute:SetParentIndex(tbt_attribute.Parent.NumChildren-1)

end

function _M.Reset(self,data,score_compare)
	if self.comps1 then
		self.comps1.node:RemoveFromParent(true)
	end
	if self.comps2 then
		self.comps2.node:RemoveFromParent(true)
	end
	for _,v in ipairs(self.btns or {}) do
		v.Visible = false
	end
	if self.root then
		Init(self, self.root, data, score_compare)
	elseif self.menu then
		local cvs_bag = self.menu:GetComponent('cvs_GearInfo')
	end

	
	local pan = self.root:FindChildByEditName('sp_GearInfo',true)
	pan.Visible = false
	local fa = DelayAction.New()
  fa.Duration = 0.1
  fa.ActionFinishCallBack = function (sender)
  	pan.Visible = true
 	end
 	self.root:AddAction(fa)
 	
end

function _M.Close(self)
	self.menu:Close()
end

function _M.SubsrcibButton(self,...)
	local funcs = {...}
	for i=1,#funcs do
		local btn = self.btns[i]
		if btn then
			btn.Visible = true
			btn.TouchClick = function ()
				funcs[i]()
			end
		end
	end
end

function _M.ResetButtonPos(self,anchor)
	local count = 0 
	for i,v in ipairs(self.btns) do
		if i == 1 then
			v.X = self.left_buttonx
		end
		if v.Visible then
			count = count + 1
		end
	end

	if count == 1 then
		if anchor == 'R' then
			self.btns[1].X = self.btns[2].X
		elseif anchor == 'L' then
		else
			self.btns[1].X = self.btns[4].X
			self.btns[1].Width = self.btns[4].Width
		end
	end
end

local function CreateWithXml(data ,score_compare)
	local ret = {}
	setmetatable(ret,_M)
	local menu = LuaMenuU.Create("xmds_ui/bag/item_information02.gui.xml",GlobalHooks.UITAG.GameUIItemDetail)
	menu.CacheLevel = -1
	menu.ShowType = UIShowType.Cover
	menu.Enable = false
	menu.mRoot.Enable = false
	
	
	
	
	ret.btns = {
		menu:GetComponent('btn_1'),
		menu:GetComponent('btn_2'),
		menu:GetComponent('btn_3'),
		menu:GetComponent('btn_4'),
	}
	ret.left_buttonx = ret.btns[1].X
	for _,v in ipairs(ret.btns) do
		v.Visible = false
	end
	local cvs_bag = menu:GetComponent('cvs_GearInfo')
	ret.content_width = cvs_bag.Width - 50
	ret.menu = menu
	Init(ret, cvs_bag, data,score_compare)
	
	return ret
end

local function CreateWithRoot(root, data)
	local ret = {}
	ret.content_width = root.Width - 50
	setmetatable(ret,_M)
	Init(ret, root, data)
	return ret
end


local function SetMini(self,data)
	local cvs_bag = self.menu:GetComponent('cvs_details')
	cvs_bag.Enable = false
	self.content_width = cvs_bag.Width - 20
	local comps1,comps2
	if data.equip then
		comps1 = mini_equip_begin(self.content_width,data,10)
		if data.equip.isIdentfied == 1 then
			comps2 = equip_content(self.content_width,data,10)
		else
			comps2 = equip_unidentify_content_mini(self.content_width,data.equip,10)
		end
	else
		comps1 = mini_normal_begin(self.content_width,data,10)
		local txt = string.format("<f size='22' color='ff5bc61a'>%s</f>",data.static.Desc)
		comps2 = normal_content(self.content_width,data,10)
	end
	cvs_bag:AddChild(comps1.node)	
	comps1.node.Y = 10
	comps2.node.Y = comps1.node.Y + comps1.node.Height + 10
	cvs_bag:AddChild(comps2.node)

	local h = comps2.node.Y + comps2.node.Height + 20
	cvs_bag.Height = h
	cvs_bag.Y = 0.5*(self.menu.mRoot.Height - h)

	self.content_node = cvs_bag
end

local function Set(self,data)
	if self.menu.Tag == GlobalHooks.UITAG.GameUISimpleDetail then
		SetMini(self,data)
	end
end

local function AddExtraNode(self,node)
	local cvs_bag = self.menu:GetComponent('cvs_details')
	cvs_bag:AddChild(node)
	node.Y = cvs_bag.Height
	cvs_bag.Height = cvs_bag.Height + node.Height
end

local function CreateWithMiniXml(tag)
	local ret = {}
	setmetatable(ret,_M)
	ret.menu = LuaMenuU.Create("xmds_ui/tips/tips_details.gui.xml",tag)
	ret.menu.CacheLevel = -1
	ret.menu.ShowType = UIShowType.Cover
	ret.menu.Enable = true
	ret.menu.event_PointerClick = function (sender)
        ret:Close()
	end
	
	

	return ret
end

_M.Set = Set
_M.AddExtraNode = AddExtraNode
_M.CreateWithXml = CreateWithXml
_M.CreateWithRoot = CreateWithRoot
_M.CreateWithMiniXml = CreateWithMiniXml
_M.equip_content = equip_content
_M.TXT_COLOR = TXT_COLOR
_M.Text = Text
return _M
