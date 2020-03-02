using UnityEngine;
using System.Collections;
using System;
using XUtliPoolLib;

public static class WrapFile
{

    public static BindType[] binds = new BindType[]
    {
        _GT(typeof(object)),
        _GT(typeof(System.String)),
        _GT(typeof(System.Enum)),   
        _GT(typeof(IEnumerator)),
        _GT(typeof(System.Delegate)),        
        _GT(typeof(Type)).SetBaseName("System.Object"),                                                     
        _GT(typeof(UnityEngine.Object)),
        _GT(typeof(System.IO.BinaryReader)),
        
        //测试模板
        ////_GT(typeof(Dictionary<int,string>)).SetWrapName("DictInt2Str").SetLibName("DictInt2Str"),
        
        //custom    
        //_GT(typeof(WWW)),
        //_GT(typeof(Util)),
		_GT(typeof(AppConst)),
        _GT(typeof(LuaEnumType)),
        _GT(typeof(Debugger)),
        _GT(typeof(DelegateFactory)),
        //_GT(typeof(TestLuaDelegate)),
        //_GT(typeof(TestDelegateListener)),
        //_GT(typeof(TestEventListener)),
        
        //unity                        
        _GT(typeof(Component)),
        _GT(typeof(Behaviour)),
        _GT(typeof(MonoBehaviour)),        
        _GT(typeof(GameObject)),
        _GT(typeof(Transform)),
         _GT(typeof(PlayerPrefs)),
        //_GT(typeof(Space)),

        _GT(typeof(Camera)),   
        //_GT(typeof(CameraClearFlags)),           
        //_GT(typeof(Material)),
        //_GT(typeof(Renderer)),        
        //_GT(typeof(MeshRenderer)),
        //_GT(typeof(SkinnedMeshRenderer)),
        //_GT(typeof(Light)),
        //_GT(typeof(LightType)),     
        //_GT(typeof(ParticleEmitter)),
        //_GT(typeof(ParticleRenderer)),
        //_GT(typeof(ParticleAnimator)),        
                
        //_GT(typeof(Physics)),
        _GT(typeof(Collider)),
        _GT(typeof(BoxCollider)),
        //_GT(typeof(MeshCollider)),
        //_GT(typeof(SphereCollider)),
        
        //_GT(typeof(CharacterController)),

        //_GT(typeof(Animation)),             
        //_GT(typeof(AnimationClip)).SetBaseName("UnityEngine.Object"),
        //_GT(typeof(TrackedReference)),
        //_GT(typeof(AnimationState)),  
        //_GT(typeof(QueueMode)),  
        //_GT(typeof(PlayMode)),                  
        
        //_GT(typeof(AudioClip)),
        //_GT(typeof(AudioSource)),                
        
        _GT(typeof(Application)),
        _GT(typeof(Input)),    
        //_GT(typeof(TouchPhase)),            
        //_GT(typeof(KeyCode)),             
        _GT(typeof(Screen)),
        _GT(typeof(Time)),
        //_GT(typeof(RenderSettings)),
        //_GT(typeof(SleepTimeout)),        

        //_GT(typeof(AsyncOperation)).SetBaseName("System.Object"),
        _GT(typeof(AssetBundle)),   
        //_GT(typeof(BlendWeights)),   
        //_GT(typeof(QualitySettings)),          
        //_GT(typeof(AnimationBlendMode)),    
        //_GT(typeof(Texture)),
        //_GT(typeof(RenderTexture)),
        //_GT(typeof(ParticleSystem)),
        

        _GT(typeof(UICamera)),
        _GT(typeof(Localization)),
        _GT(typeof(NGUITools)),

        _GT(typeof(UIRect)),
        _GT(typeof(UIWidget)),        
        _GT(typeof(UIWidgetContainer)),     
        _GT(typeof(UILabel)),        
        _GT(typeof(UIToggle)),    
        _GT(typeof(UITexture)),
        _GT(typeof(UIButton)),
        _GT(typeof(UIButtonColor)),
        _GT(typeof(UISprite)),           
        _GT(typeof(UIProgressBar)),
        _GT(typeof(UISlider)),
        _GT(typeof(UIGrid)),
        _GT(typeof(UIInput)),
        _GT(typeof(UIScrollView)),
        _GT(typeof(UITable)),
        _GT(typeof(UIEventListener)),
        _GT(typeof(EventDelegate)),

        //_GT(typeof(UITweener)),
        //_GT(typeof(UIPlayTween)),
        //_GT(typeof(TweenWidth)),
        //_GT(typeof(TweenRotation)),
        //_GT(typeof(TweenPosition)),
        //_GT(typeof(TweenScale)),
        _GT(typeof(UICenterOnChild)),    
        _GT(typeof(UIAtlas)),    
   
        _GT(typeof(PrivateExtensions)),
        _GT(typeof(PublicExtensions)),
        _GT(typeof(Hotfix)),
        _GT(typeof(HotfixManager)),
        _GT(typeof(LuaEngine)),

        //_GT(typeof(LuaDelegate01)),
        //_GT(typeof(LuaTestDel)),
        _GT(typeof(DelManager)),
        _GT(typeof(LuaStringBuffer)),
        _GT(typeof(LuaUIManager)).SetBaseName("System.Object"),
        _GT(typeof(LuaGameInfo)).SetBaseName("System.Object"),
        _GT(typeof(LuaDlg)),
        _GT(typeof(UIDummy)),
        _GT(typeof(TestProtol)),
        _GT(typeof(XLuaLong)),
        _GT(typeof(XFile)),
        _GT(typeof(XDirectory)),
    };

    public static BindType _GT(Type t)
    {
        return new BindType(t);
    }


}
