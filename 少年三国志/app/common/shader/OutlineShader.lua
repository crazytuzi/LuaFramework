local OutlineShader = {}

function OutlineShader.createShader(key) 


--vert
local vertDesc =  [[
attribute vec4 a_position;                        
attribute vec2 a_texCoord;                         
attribute vec4 a_color;                            
                                                   
#ifdef GL_ES                                        
varying lowp vec4 v_fragmentColor;                 
varying mediump vec2 v_texCoord;                   
#else                                               
varying vec4 v_fragmentColor;                      
varying vec2 v_texCoord;                           
#endif                                              
                                                    
void main()                                        
{                                                  
    gl_Position = CC_MVPMatrix * a_position;       
    v_fragmentColor = a_color;                      
    v_texCoord = a_texCoord;                       
}                                                  
]]




    local fragDesc = [[


    #ifdef GL_ES                               
    precision lowp float;                      
    #endif                                      
                                               
    varying vec4 v_fragmentColor;              
    varying vec2 v_texCoord;                    
    uniform sampler2D CC_Texture0;  
    uniform vec2 textSize;  
    uniform vec3 outlineColor;  
    uniform vec3 textColor;

void main(void)
{
   
    vec2 off = textSize;
    vec2 tc = v_texCoord.st;
    vec4 gColor = v_fragmentColor;

    vec4 c = texture2D(CC_Texture0, tc);




    vec4 n = texture2D(CC_Texture0, vec2(tc.x, tc.y - off.y));
    vec4 e = texture2D(CC_Texture0, vec2(tc.x + off.x, tc.y));
    vec4 s = texture2D(CC_Texture0, vec2(tc.x, tc.y + off.y));
    vec4 w = texture2D(CC_Texture0, vec2(tc.x - off.x, tc.y));
    

    float ua = 0.0;

    ua = mix(ua, 1.0, c.a);
    ua = mix(ua, 1.0, n.a);
    ua = mix(ua, 1.0, e.a);
    ua = mix(ua, 1.0, s.a);
    ua = mix(ua, 1.0, w.a);

    vec4 origColor = c * gColor;
  

    vec4 underColor = vec4(outlineColor,1.0) * vec4(ua);
    gl_FragColor = mix(underColor, origColor, origColor.a );

    //sharpen the outline 
    if (gl_FragColor.a > 0.1) {
        gl_FragColor.a = clamp(gl_FragColor.a*1.1, 0., 1.);
    }


    //if (ua <= 0.9) {
        //make some blur effect
        //vec4 target = 5.0 *gl_FragColor;
        //target += n + e + s + w;
        //target /= 5.;
        //gl_FragColor = target;
    //}




 
}                                        
    ]]



    FuncHelperUtil:addShaderWithKey(key, vertDesc, fragDesc)
  
end




function OutlineShader.createShader3(key) 


--vert
local vertDesc =  [[
attribute vec4 a_position;                        
attribute vec2 a_texCoord;                         
attribute vec4 a_color;                            
                                                   
#ifdef GL_ES                                        
varying lowp vec4 v_fragmentColor;                 
varying mediump vec2 v_texCoord;                   
#else                                               
varying vec4 v_fragmentColor;                      
varying vec2 v_texCoord;                           
#endif                                              
                                                    
void main()                                        
{                                                  
    gl_Position = CC_MVPMatrix * a_position;       
    v_fragmentColor = a_color;                      
    v_texCoord = a_texCoord;                       
}                                                  
]]



-- uniform sampler2D tex;
-- uniform vec2 texSize;
-- uniform vec4 outlineColor;

    local fragDesc = [[


    #ifdef GL_ES                               
    precision lowp float;                      
    #endif                                      
                                               
    varying vec4 v_fragmentColor;              
    varying vec2 v_texCoord;                    
    uniform sampler2D CC_Texture0;  
    uniform vec2 textSize;  
    uniform vec3 outlineColor;  
    uniform vec3 textColor;

void main(void)
{
    //    vec2 off = vec2(0.005, 0.01);

    //vec2 size = vec2(300.0,50.0);
    ///vec2 size = vec2(120.0,25.0);

    vec2 off = vec2(1.0/textSize);
    vec2 tc = v_texCoord.st;
    vec4 gColor = v_fragmentColor;

    vec4 c = texture2D(CC_Texture0, tc);




    vec4 n = texture2D(CC_Texture0, vec2(tc.x, tc.y - off.y));
    vec4 e = texture2D(CC_Texture0, vec2(tc.x + off.x, tc.y));
    vec4 s = texture2D(CC_Texture0, vec2(tc.x, tc.y + off.y));
    vec4 w = texture2D(CC_Texture0, vec2(tc.x - off.x, tc.y));
    

float d = 0.0;
float d2 =0.0;
float d3 = 0.0;
    float ua = 0.0;
    ua = mix(ua, 1.0, c.a);
    ua = mix(ua, 1.0, n.a);
    ua = mix(ua, 1.0, e.a);
    ua = mix(ua, 1.0, s.a);
    ua = mix(ua, 1.0, w.a);
   

  //ua *= 1.3;


    vec4 underColor = vec4(outlineColor,1.0) * vec4(ua);

  gl_FragColor = mix(underColor, gColor, c.a);

 
}                                        
    ]]



    FuncHelperUtil:addShaderWithKey(key, vertDesc, fragDesc)
  
end



function OutlineShader.createShader2(key) 


--vert
local vertDesc =  [[
attribute vec4 a_position;                        
attribute vec2 a_texCoord;                         
attribute vec4 a_color;                            
                                                   
#ifdef GL_ES                                        
varying lowp vec4 v_fragmentColor;                 
varying mediump vec2 v_texCoord;                   
#else                                               
varying vec4 v_fragmentColor;                      
varying vec2 v_texCoord;                           
#endif                                              
                                                    
void main()                                        
{                                                  
    gl_Position = CC_MVPMatrix * a_position;       
    v_fragmentColor = a_color;                      
    v_texCoord = a_texCoord;                       
}                                                  
]]



-- uniform sampler2D tex;
-- uniform vec2 texSize;
-- uniform vec4 outlineColor;

    local fragDesc = [[


    #ifdef GL_ES                               
    precision lowp float;                      
    #endif                                      
                                               
    varying vec4 v_fragmentColor;              
    varying vec2 v_texCoord;                    
    uniform sampler2D CC_Texture0;  


void main(void)
{
    //    vec2 off = vec2(0.005, 0.01);

    //vec2 size = vec2(300.0,50.0);
    vec2 size = vec2(120.0,25.0);

    vec2 off = vec2(0.0005,0.0005);
    vec2 tc = v_texCoord.st;
    vec4 outlineColor = vec4(0.0,0.0,0.0,1.0);
    vec4 gColor = vec4(0.0,1.0,1.0,1.0);

    vec4 c = texture2D(CC_Texture0, tc);

    //if (c.a >= 0.9) {
   //     gl_FragColor = gColor;//vec4(1.0,0.0,0.0,1.0);
   //     return;
   // }



    //vec4 gl_Color = texture2D(CC_Texture0, vec2(v_texCoord.s,v_texCoord.t));
    vec4 n = texture2D(CC_Texture0, vec2(tc.x, tc.y - off.y));
    vec4 e = texture2D(CC_Texture0, vec2(tc.x + off.x, tc.y));
    vec4 s = texture2D(CC_Texture0, vec2(tc.x, tc.y + off.y));
    vec4 w = texture2D(CC_Texture0, vec2(tc.x - off.x, tc.y));
    
    //vec4 origColor = c * gColor;

float d = 0.0;
float d2 =0.0;
float d3 = 0.0;
    float ua = 0.0;
    ua = mix(ua, 1.0, c.a);
    ua = mix(ua, 1.0, n.a);
    ua = mix(ua, 1.0, e.a);
    ua = mix(ua, 1.0, s.a);
    ua = mix(ua, 1.0, w.a);


    if (ua <= 0.1) {
        gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
        return;
    } else if (ua <= 0.3) {
        gl_FragColor = vec4(0.0, 0.0, 0.3, 1.0);
        return;
    } else if (ua <= 0.5) {
        gl_FragColor = vec4(0.0, 0.0, 0.8, 1.0);
        return;
    }else if (ua <= 0.7) {
        gl_FragColor = vec4(0.0, 0.2, 0.0, 1.0);
        return;
    }else if (ua <= 0.9) {
        gl_FragColor = vec4(0.0, 0.5, 0.0, 1.0);
        return;
    }else if (ua <= 0.95) {
        gl_FragColor = vec4(0.0, 0.8, 0.0, ua);
        return;
    }else if (ua <= 0.98) {
        gl_FragColor = vec4(0.0, 0.5, 0.5, ua);
        return;
    }else if (ua <= 0.99) {
        gl_FragColor = vec4(0.0, 0.8, 0.8, ua);
        return;
    }else if (ua  >= 1.0) {
        gl_FragColor = vec4(0.0, 1.0, 0.2, ua);
        return;
    }

gl_FragColor = vec4(1.0, 1.0, 0.0, 1.0);
        return;
    // underColor = outlineColor * vec4(ua);

  ///  gl_FragColor = mix(underColor, gColor, c.a);

 
}                                        
    ]]



    FuncHelperUtil:addShaderWithKey(key, vertDesc, fragDesc)
  
end
return OutlineShader
