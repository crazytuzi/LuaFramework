------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_global");



------------------------------------------------------
i3k_entity_title = i3k_class("i3k_entity_title");
function i3k_entity_title:ctor()
	self._title = Engine.MEntityTitle();
end

function i3k_entity_title:Create(nodeName)
	if self._title then
		return self._title:Create(nodeName);
	end

	return false;
end

function i3k_entity_title:Release()
	if self._title then
		self._title:Release();
		self._title = nil;
	end
end

function i3k_entity_title:AddTextLable(x, w, y, h, color, text)
	if not self._title then
		return -1;
	end

	local _name = Engine.TitleTextInfo();
		_name.mName			= text;
		_name.mFont			= i3k_db_common.engine.defaultFont;
		_name.mFontSize		= 22; -- 22 + 3 * 2 + 4 == 32(total pow of two)
		_name.mTextColor	= color;
		_name.mItemX		= x;
		_name.mItemW		= w;
		_name.mItemY		= y;
		_name.mItemH		= h;
		_name.mThickness	= 3;
		_name.mShow			= true;
	return self._title:AddTextLable(_name);
end

function i3k_entity_title:UpdateTextLable(idx, text, updateText, color, updateColor)
	if self._title then
		self._title:UpdateTextLable(idx, text, updateText, color, updateColor);
	end
end

function i3k_entity_title:AddImgLable(x, w, y, h, img)
	if not self._title then
		return -1;
	end

	local _img = Engine.TitleImgInfo();
		_img.mImg		= img;
		_img.mItemX		= x;
		_img.mItemW		= w;
		_img.mItemY		= y;
		_img.mItemH		= h;
		_img.mShow		= true;
	return self._title:AddImgLable(_img);
end

function i3k_entity_title:AddBloodBar(x, w, y, h, isRed)
	if not self._title then
		return -1;
	end

	local _blood = Engine.TitleBloodInfo();
		_blood.mItemX			= x;
		_blood.mItemW			= w;
		_blood.mItemY			= y;
		_blood.mItemH			= h;
		_blood.mBloodImg		= i3k_db_common.engine.texBloodGreen;
		if isRed then
			_blood.mBloodImg	= i3k_db_common.engine.texBloodRed
		end
		_blood.mBloodBkImg		= i3k_db_common.engine.texBloodYellow;
		_blood.mFadeRight		= true;
		_blood.mBloodFadeTime	= i3k_db_common.engine.bloodFadeTime or 100;
		_blood.mBloodBorderImg	= i3k_db_common.engine.texBloodBorder;
		_blood.mBorderWidth		= 0.015;
		_blood.mShow			= true;
	return self._title:AddBloodBar(_blood);
end

function i3k_entity_title:UpdateBloodBar(idx, percent)
	if self._title then
		self._title:UpdateBloodBar(idx, percent);
	end
end

function i3k_entity_title:SetVisible(vis)
	if self._title then
		self._title:SetVisible(vis or false);
	end
end

function i3k_entity_title:SetElementVisiable(idx,vis)
	if self._title then
		self._title:SetElementVisible(idx, vis);
	end
end

function i3k_entity_title:EnterWorld()
	if self._title then
		self._title:EnterWorld();
	end
end

function i3k_entity_title:LeaveWorld()
	if self._title then
		self._title:LeaveWorld();
	end
end

function i3k_entity_title:GetTitle()
	return self._title;
end
