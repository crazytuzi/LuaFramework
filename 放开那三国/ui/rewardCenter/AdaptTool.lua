-- Filename: AdaptTool.lua
-- Author: lichenyang
-- Date: 2013-08-12
-- Purpose: 屏幕适配工具

module("AdaptTool", package.seeall)

function setAdaptNode( node )
	local deviceHeith = CCDirector:sharedDirector():getWinSize().height;
    local deviceWidth = CCDirector:sharedDirector():getWinSize().width;
    local x = deviceWidth/640;
    local y = deviceHeith/960;
    if (x > y) then
    	node:setScale(y);
    else
        node:setScale(x);
    end
    return node
end


function getScaleParm( )
    local deviceHeith = CCDirector:sharedDirector():getWinSize().height;
    local deviceWidth = CCDirector:sharedDirector():getWinSize().width;
    local x = deviceWidth/640;
    local y = deviceHeith/960;
    if (x > y) then
        return  x
    else
       return  y
    end
end
