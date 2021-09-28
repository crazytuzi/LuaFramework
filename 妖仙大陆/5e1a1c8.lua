

local Helper = require 'Zeus.Logic.Helper'
local Util   = require 'Zeus.Logic.Util'

local _M = {}
_M.__index = _M

local TEMPLATE_UI = nil

local function init_template_ui()
	if TEMPLATE_UI then return end
	TEMPLATE_UI = {
		normal_begin_template = {
			X=25,
			{id="secondType",HZLabel.CreateLabel,FontSize=FONT_SMALL,Color=0xffffffff,TextAnchor=TextAnchor.R_T,X=CONTENT_WIDTH},
			{
				direction='h',
				{id="num",HZLabel.CreateLabel,FontSize=FONT_MIDDLE,Color=0xffffffff,Y=-10},
				{id="bind",HZLabel.CreateLabel,FontSize=FONT_SMALL,Color=0xffffffff,TextAnchor=TextAnchor.R_T,X=CONTENT_WIDTH},
			},
			{id="maxNum",HZLabel.CreateLabel,FontSize=FONT_MIDDLE,Color=0xffffffff},
			{id="useLevel",HZLabel.CreateLabel,FontSize=FONT_MIDDLE,Color=0xffffffff},
		}, 	
		normal_content_template = {
			{HZImageBox.New,Img='#dynamic_n/dynamic_pic/dynamic001.xml|dynamic001|27',Y=10,padding=15},
			{id='desc1',HZTextBoxHtml.New,ContentW=CONTENT_WIDTH,padding=30},
			{id='desc2',HZTextBoxHtml.New,ContentW=CONTENT_WIDTH},
		},
		equip_begin_template = {
			X=25,
			{id="secondType",HZLabel.CreateLabel,FontSize=FONT_SMALL,Color=0xffffffff,TextAnchor=TextAnchor.R_T,X=CONTENT_WIDTH},
			{
				direction='h',
				{id="proLimit",HZLabel.CreateLabel,FontSize=FONT_MIDDLE,Color=0xffffffff,Y=-10},
				{id="bind",HZLabel.CreateLabel,FontSize=FONT_SMALL,Color=0xffffffff,TextAnchor=TextAnchor.R_T,X=CONTENT_WIDTH},
			},
			{	
				
				direction='h',
				{id="level",HZLabel.CreateLabel,FontSize=FONT_MIDDLE,Color=0xffffffff},
				{id="score",HZLabel.CreateLabel,FontSize=FONT_SMALL,Color=0xef880eff,TextAnchor=TextAnchor.R_T,X=CONTENT_WIDTH,Y=3},
			}
		},
		equip_unident_content_template = {
			{HZImageBox.New,Img='#dynamic_n/dynamic_pic/dynamic001.xml|dynamic001|27',Y=10,padding=10},
			{
				id='mainAttrContent',
				{
					id='mainAttrArray',
					direction='h',
					padding=10,
					
					{sub_id='img',HZImageBox.New,Img='#static_n/static_pic/static001.xml|static001|42',Y=9,padding=8},
					{sub_id='attr',HZLabel.CreateLabel,FontSize=FONT_MIDDLE,Color=TXT_COLOR.WHITE},
				},
				{HZImageBox.New,Img='#dynamic_n/dynamic_pic/dynamic001.xml|dynamic001|27',padding=10},
			},
			{id='identifyDesc',HZTextBoxHtml.New,X=15,ContentW=CONTENT_WIDTH,padding=20},
			{HZImageBox.New,Img='#dynamic_n/dynamic_pic/dynamic001.xml|dynamic001|27',padding=10},
			{id='identifyCostDesc',HZTextBoxHtml.New,X=15,ContentW=CONTENT_WIDTH,padding=20},
		},
		equip_content_template = {
			{HZImageBox.New,Img='#dynamic_n/dynamic_pic/dynamic001.xml|dynamic001|27',Y=10,padding=10},
			{
				id='mainAttrContent',
				
				
				
				
				
				
				{
					direction='h',
					{				
						{
							
							id='mainAttrArray',
							direction='h',
							{sub_id='img',HZImageBox.New,Img='#static_n/static_pic/static001.xml|static001|42',Y=9,padding=8},
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
					padding=10,
				},
				{HZImageBox.New,Img='#dynamic_n/dynamic_pic/dynamic001.xml|dynamic001|27',padding=10},
			},
			{
				
				id='randomContent',
				{
					id='randomAttrs',
					direction='h',
					
					
					{sub_id='img',HZImageBox.New,Img='#static_n/static_pic/static001.xml|static001|42',Y=9,padding=8},
					{sub_id='attr',HZLabel.CreateLabel,FontSize=FONT_MIDDLE,Color=TXT_COLOR.WHITE},
				},
				{HZImageBox.New,Img='#dynamic_n/dynamic_pic/dynamic001.xml|dynamic001|27',padding=10},
			},
			
			{
				id='gemContent',
				{
					direction='h',
					id='gemAttrs',
					
					{sub_id='img',HZImageBox.New,padding=8,Y=4,W=25,H=25},
					{sub_id='attr',HZLabel.CreateLabel,FontSize=FONT_MIDDLE},
				},
				{HZImageBox.New,Img='#dynamic_n/dynamic_pic/dynamic001.xml|dynamic001|27',padding=10},
			},
			{id='desc1',HZTextBoxHtml.New,X=15,ContentW=CONTENT_WIDTH,padding=20},			
		},
	}
end

local function Close(self)
  self.menu:Close()  
end



local Text = {
  
}

local function OnEnter(self)
  
end

local function OnExit(self)
  
end

local function OnDestory(self)
  
end

local ui_names = 
{
  
  
}

local function InitComponent(self,tag)
	
	self.menu = LuaMenuU.Create('xmds_ui/tips/tips_detail.gui.xml',tag)
	Util.CreateHZUICompsTable(self.menu,ui_names,self)

  self.menu:SubscribOnExit(function ()
    OnExit(self)
  end)
  self.menu:SubscribOnEnter(function ()
    OnEnter(self)
  end)
  self.menu:SubscribOnDestory(function ()
    OnDestory(self)
  end)
end


local function Create(tag)
  local ret = {}
  setmetatable(ret, _M)
  InitComponent(ret,tag)
  return ret
end

_M.Create = Create
_M.Close  = Close

return _M
