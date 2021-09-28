-- Filename: AudioUtil.lua
-- Author: k
-- Date: 2013-08-03
-- Purpose: audio



require "script/utils/extern"
--require "amf3"
-- 主城场景模块声明
module("AudioUtil", package.seeall)

local m_currentBgm       --当前背景音乐

m_isBgmOpen = nil

m_isSoundEffectOpen = nil

local _bgmFile = nil


local IMG_PATH = "audio/"               -- 图片主路径

local mPreloadEffect = nil

local mPreloadCount = 0

local mMaxPreload = 32

local musicprotocol

function initAudioInfo()
    if(CCUserDefault:sharedUserDefault():getBoolForKey("isAudioInit")==false)then
        CCUserDefault:sharedUserDefault():setBoolForKey("isAudioInit",true)
        CCUserDefault:sharedUserDefault():setBoolForKey("m_isBgmOpen",true)
        CCUserDefault:sharedUserDefault():setBoolForKey("m_isSoundEffectOpen",true)
        CCUserDefault:sharedUserDefault():flush()
        
        m_isBgmOpen = true
        m_isSoundEffectOpen = true
    else
        m_isBgmOpen = CCUserDefault:sharedUserDefault():getBoolForKey("m_isBgmOpen")
        m_isSoundEffectOpen = CCUserDefault:sharedUserDefault():getBoolForKey("m_isSoundEffectOpen")
        if ( g_system_type == kBT_PLATFORM_IOS or g_system_type == kBT_PLATFORM_ANDROID) then
            if(m_isBgmOpen==true)then
                SimpleAudioEngine:sharedEngine():setBackgroundMusicVolume(1)
            else
                SimpleAudioEngine:sharedEngine():setBackgroundMusicVolume(0)
            end
        else
            if(NSBundleInfo:getAppVersion() <= "3.0.1") then
                if(m_isBgmOpen==true)then
                    SimpleAudioEngine:sharedEngine():setBackgroundMusicVolume(1)
                else
                    SimpleAudioEngine:sharedEngine():setBackgroundMusicVolume(0)
                end
            else
                if(m_isBgmOpen==true)then
                    Platform.setMusicVolume("1")
                else
                    Platform.setMusicVolume("0")
                end
            end

        end
       
        if(m_isSoundEffectOpen==true)then
            SimpleAudioEngine:sharedEngine():setEffectsVolume(1)
            else
            SimpleAudioEngine:sharedEngine():setEffectsVolume(0)
        end
    end
end

-- 得到当前背景的路径
function getBgmFile( ... )
    return _bgmFile
end

--播放背景音乐
function playBgm(bgm,isLoop)
    if(bgm)then
        _bgmFile = bgm
    else
        bgm = _bgmFile
    end
    if(nil==m_isBgmOpen)then
        initAudioInfo()
    end

    isLoop = isLoop==nil and true or isLoop
    if(g_system_type == kBT_PLATFORM_IOS or g_system_type == kBT_PLATFORM_ANDROID) then
        if(bgm~=m_currentBgm)then
            m_currentBgm = bgm
            if(m_isBgmOpen==true)then
                SimpleAudioEngine:sharedEngine():playBackgroundMusic(m_currentBgm,isLoop)
            else
                SimpleAudioEngine:sharedEngine():playBackgroundMusic(m_currentBgm,isLoop)
                SimpleAudioEngine:sharedEngine():setBackgroundMusicVolume(0)
            end
        end
    else
        if(NSBundleInfo:getAppVersion() <= "3.0.1") then
            bgm = changeToWav(bgm)
          --  file,err = io.open(bgm)
          --  if(file ~= nil) then
                if(bgm~=m_currentBgm)then
                  m_currentBgm = bgm
                  SimpleAudioEngine:sharedEngine():playBackgroundMusic(m_currentBgm,isLoop)
                end
          --  end
        else
            if(bgm~=m_currentBgm)then
                 m_currentBgm = bgm
                 if(m_isBgmOpen==true)then
                    Platform.playMusicBmg(m_currentBgm,isLoop)
                 else
                    Platform.playMusicBmg(m_currentBgm,isLoop)
                    Platform.setMusicVolume("0")
                 end
            end
        end
    end
   
end

--停止背景音乐
function stopBgm()
    
    if(nil==m_isBgmOpen)then
        initAudioInfo()
    end
    if(NSBundleInfo:getAppVersion() <= "3.0.1") then
         print("执行3.0.1-stopbgm")
        m_currentBgm = nil
        SimpleAudioEngine:sharedEngine():stopBackgroundMusic()
    else
        m_currentBgm = nil
        if ( g_system_type == kBT_PLATFORM_IOS or g_system_type == kBT_PLATFORM_ANDROID) then
            SimpleAudioEngine:sharedEngine():stopBackgroundMusic()
        else
            Platform.stopMusicBmg()
        end
    end
end

local function checkEffect(effect)
    if mPreloadEffect == nil then
        mPreloadEffect = {}
    end

    local nowTime = os.time()
    if mPreloadEffect[effect] == nil then
        mPreloadCount = mPreloadCount + 1
    end

    mPreloadEffect[effect] = nowTime
    print("mPreloadCount",mPreloadCount)
    if mPreloadCount < mMaxPreload then
        return
    end
    
    local minTime = nowTime + 1
    local minEffect = nil
    for key, time in pairs(mPreloadEffect) do
        if key ~= effect and time < minTime then
            minTime = time
            minEffect = key
        end
    end

    print("unload " .. minEffect)
    SimpleAudioEngine:sharedEngine():unloadEffect(minEffect)
    mPreloadCount = mPreloadCount - 1
    mPreloadEffect[minEffect] = nil
end

--播放音效
function playEffect(effect,isLoop)
    effect = changeToWav(effect)
    if(nil==m_isSoundEffectOpen)then
        initAudioInfo()
    end
    
    isLoop = isLoop==nil and false or isLoop
    --print("AudioUtil.playEffect effect:",effect)
    local effectId = 1
    if(m_isSoundEffectOpen==true)then
        if(file_exists(effect)) then
            checkEffect(effect)
            effectId = SimpleAudioEngine:sharedEngine():playEffect(effect,isLoop)
        end
    end
    return effectId
end

-- 停止播放音效
function stopEffect( pEffectId )
    if( pEffectId == nil)then
        return
    end
    SimpleAudioEngine:sharedEngine():stopEffect(pEffectId)
end

--关闭背景音乐
function muteBgm()
    m_isBgmOpen = false
     if(NSBundleInfo:getAppVersion() <= "3.0.1") then
         print("执行3.0.1-mutebgm")
        SimpleAudioEngine:sharedEngine():setBackgroundMusicVolume(0)
     else
        if (g_system_type == kBT_PLATFORM_IOS or g_system_type == kBT_PLATFORM_ANDROID) then
            SimpleAudioEngine:sharedEngine():setBackgroundMusicVolume(0)
            print("关闭执行这里IOS&ANDROID:",g_system_type)
        else
            Platform.setMusicVolume("0")
            print("关闭执行这里WP:",g_system_type)
        end
     end
    CCUserDefault:sharedUserDefault():setBoolForKey("m_isBgmOpen",false)
    CCUserDefault:sharedUserDefault():flush()
end
--开启背景音乐
function openBgm()
    m_isBgmOpen = true
     if(NSBundleInfo:getAppVersion() <= "3.0.1") then
         print("执行3.0.1-openbgm")
        SimpleAudioEngine:sharedEngine():setBackgroundMusicVolume(1)
     else
        if (g_system_type == kBT_PLATFORM_IOS or g_system_type == kBT_PLATFORM_ANDROID) then
            SimpleAudioEngine:sharedEngine():setBackgroundMusicVolume(1)
            print("开启执行这里IOS&ANDROID:",g_system_type)
        else
            Platform.setMusicVolume("1")
            print("开启执行这里WP:",g_system_type)
        end
     end 
  
    CCUserDefault:sharedUserDefault():setBoolForKey("m_isBgmOpen",true)
    CCUserDefault:sharedUserDefault():flush()
end
--关闭音效
function muteSoundEffect()
    m_isSoundEffectOpen = false
    SimpleAudioEngine:sharedEngine():setEffectsVolume(0)
    CCUserDefault:sharedUserDefault():setBoolForKey("m_isSoundEffectOpen",false)
    CCUserDefault:sharedUserDefault():flush()
end
--开启音效
function openSoundEffect()
    m_isSoundEffectOpen = true
    SimpleAudioEngine:sharedEngine():setEffectsVolume(1)
    CCUserDefault:sharedUserDefault():setBoolForKey("m_isSoundEffectOpen",true)
    CCUserDefault:sharedUserDefault():flush()
end

--播放背景音乐
function playMainBgm()
    playBgm("audio/main.mp3")
end
-- 退出场景，释放不必要资源
function release (...) 
    AudioUtil = nil
    package.loaded["AudioUtil"] = nil
    for k, v in pairs(package.loaded) do
        local s, e = string.find(k, "/AudioUtil")
        if s and e == string.len(k) then
            package.loaded[k] = nil
        end
    end
end

--如果是wp系统, 把mp3转为wav
function changeToWav( name )
    if(Platform.getOS() == "wp")then
        if(name == nil) then return "" end
        return string.gsub(name,".mp3",".wav")
    end
    return name
end
