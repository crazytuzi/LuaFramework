--[[

Copyright (c) 2011-2015 chukong-incc.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

]]

require "thirdlibs.cocos.cocos2d.Cocos2d"
require "thirdlibs.cocos.cocos2d.Cocos2dConstants"
require "thirdlibs.cocos.cocos2d.functions"

__G__TRACKBACK__ = function(msg)
    local msg = debug.traceback(msg, 3)
    print(msg)
    return msg
end

-- opengl
require "thirdlibs.cocos.cocos2d.Opengl"
require "thirdlibs.cocos.cocos2d.OpenglConstants"
-- audio
-- require "thirdlibs.cocos.cocosdenshion.AudioEngine"
-- cocosstudio
-- if nil ~= ccs then
--     require "thirdlibs.cocos.cocostudio.CocoStudio"
-- end
-- ui
if nil ~= ccui then
    require "thirdlibs.cocos.ui.GuiConstants"
    require "thirdlibs.cocos.ui.experimentalUIConstants"
end

-- extensions
require "thirdlibs.cocos.extension.ExtensionConstants"
-- network
require "thirdlibs.cocos.network.NetworkConstants"
-- Spine
if nil ~= sp then
    require "thirdlibs.cocos.spine.SpineConstants"
end

require "thirdlibs.cocos.cocos2d.deprecated"
require "thirdlibs.cocos.cocos2d.DrawPrimitives"

-- Lua extensions
require "thirdlibs.cocos.cocos2d.bitExtend"

-- CCLuaEngine
require "thirdlibs.cocos.cocos2d.DeprecatedCocos2dClass"
require "thirdlibs.cocos.cocos2d.DeprecatedCocos2dEnum"
require "thirdlibs.cocos.cocos2d.DeprecatedCocos2dFunc"
require "thirdlibs.cocos.cocos2d.DeprecatedOpenglEnum"

-- register_cocostudio_module
-- if nil ~= ccs then
--     require "thirdlibs.cocos.cocostudio.DeprecatedCocoStudioClass"
--     require "thirdlibs.cocos.cocostudio.DeprecatedCocoStudioFunc"
-- end


-- register_cocosbuilder_module
-- require "thirdlibs.cocos.cocosbuilder.DeprecatedCocosBuilderClass"

-- register_cocosdenshion_module
require "thirdlibs.cocos.cocosdenshion.DeprecatedCocosDenshionClass"
require "thirdlibs.cocos.cocosdenshion.DeprecatedCocosDenshionFunc"

-- register_extension_module
require "thirdlibs.cocos.extension.DeprecatedExtensionClass"
require "thirdlibs.cocos.extension.DeprecatedExtensionEnum"
require "thirdlibs.cocos.extension.DeprecatedExtensionFunc"

-- register_network_module
require "thirdlibs.cocos.network.DeprecatedNetworkClass"
require "thirdlibs.cocos.network.DeprecatedNetworkEnum"
require "thirdlibs.cocos.network.DeprecatedNetworkFunc"

-- register_ui_moudle
if nil ~= ccui then
    require "thirdlibs.cocos.ui.DeprecatedUIEnum"
    require "thirdlibs.cocos.ui.DeprecatedUIFunc"
end

-- cocosbuilder
-- require "thirdlibs.cocos.cocosbuilder.CCBReaderLoad"

-- physics3d
-- require "thirdlibs.cocos.physics3d.physics3d-constants"

