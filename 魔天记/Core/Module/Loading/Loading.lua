Loading = {}
Loading._Path = "UI_LoadingPanel"
Loading._BgPath = "LoadBg/"

local _go = nil
local _slider = nil
local _highLight = nil
local _highSprite = nil
local _texBg = nil
local _txtDes = nil
local _lastBgPath = nil
local _mask = nil
local insert = table.insert

function Loading.Show()
    if _go then
        _go:SetActive(true)
    else
        Loading._Init()
    end
    Loading.OnProGress(0)
    Loading._SetVisible()
end
function Loading._Init()
    _go = UIUtil.GetUIGameObject(Loading._Path)
    local trs = UIUtil.GetChildByName(_go, "trsContent").gameObject
    _slider = UIUtil.GetChildByName(trs, "UISlider", "slider")
    _highLight = UIUtil.GetChildByName(_slider.gameObject,"icoHighLight")
    _highSprite = UIUtil.GetChildByName(_highLight.gameObject,"UISprite","Sprite")
    _texBg = UIUtil.GetChildByName(trs, "UITexture", "TexBg")
    _txtDes = UIUtil.GetChildByName(trs, "UILabel", "txtLoading")
    LoadingPorxy.InitConfig()
    _mask = Resourcer.Get("GUI", "UI_Screen_Mask", _go.transform)
end
function Loading._SetVisible()
    local np = Loading._BgPath .. LoadingPorxy.GetBgPath()
    if np == _lastBgPath then return end
    local t = UIUtil.GetTexture(np)
    if not IsNil(t) then _texBg.mainTexture = t
    else
        np = Loading._BgPath .. "loadingbg"
        _texBg.mainTexture = UIUtil.GetTexture(np)
    end
    _txtDes.text = LoadingPorxy.GetDes()
    Timer.New(function()        
        if _lastBgPath then UIUtil.RecycleTexture(_lastBgPath) end
        _lastBgPath = np
    end, 0.5,1):Start()
end
function Loading.Hide()
    Timer.New(Loading._Hide,0,1,true):Start()
end
function Loading._Hide()
    _go:SetActive(false)
end
function Loading.OnProGress(value)
    _slider.value = value
    _highLight.localEulerAngles = Vector3(0, 0, -360 * value)
    _highSprite.alpha = value > 0.1 and 1 or value * 10
end

function Loading.Dispone()
    if not _go then return end
    Resourcer.Recycle(_mask, false)
    _mask = nil
    if _lastBgPath then UIUtil.RecycleTexture(_lastBgPath) end
    Resourcer.Recycle(_go, false)
    _go = nil
    _slider = nil
    _highLight = nil
    _highSprite = nil
    _texBg = nil
    _txtDes = nil
    _lastBgPath = nil
end


LoadingPorxy = {}
function LoadingPorxy.InitConfig()
    local cs =  ConfigManager.GetConfig(ConfigManager.CONFIGNAME_LOADING_INFO)
    LoadingPorxy._bgPaths = {}
    LoadingPorxy._des = {}
    for i, v in pairs(cs) do
        if v.type == 1 then
            insert(LoadingPorxy._bgPaths, v.content)
        else
            insert(LoadingPorxy._des, v.content)
        end
    end
end
function LoadingPorxy.GetBgPath()
    return LoadingPorxy._bgPaths[ math.random( #LoadingPorxy._bgPaths) ]
end
function LoadingPorxy.GetDes()
    return LoadingPorxy._des[ math.random(#LoadingPorxy._des) ]
end