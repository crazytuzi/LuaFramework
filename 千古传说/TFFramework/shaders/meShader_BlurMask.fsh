#ifdef GL_ES                                    
precision lowp float;                           
#endif                                                                   
varying vec4        v_fragmentColor;            
varying vec2        v_texCoord;                 
uniform sampler2D   CC_Texture0;                  
uniform sampler2D   CC_Texture1;                     
                                                
void main()                                     
{                                               
    vec4 texColor   = texture2D(CC_Texture0, v_texCoord);                            
    vec4 c0  = texture2D(CC_Texture1, v_texCoord);                                 
    vec4 finalColor;   
    if  (texColor.a < 0.01)
    {
        finalColor = c0;        
    }
    else
    {
        vec4 c1 = texture2D(CC_Texture1, v_texCoord + vec2(0.0, 0.01)); 
        vec4 c2 = texture2D(CC_Texture1, v_texCoord + vec2(0.0, -0.01)); 
        vec4 c3 = texture2D(CC_Texture1, v_texCoord + vec2(0.01, 0.0)); 
        vec4 c4 = texture2D(CC_Texture1, v_texCoord + vec2(-0.01, 0.0)); 
    
        vec4 c5 = texture2D(CC_Texture1, v_texCoord + vec2(-0.01, 0.01));     
        vec4 c6 = texture2D(CC_Texture1, v_texCoord + vec2(-0.01, -0.01));     
        vec4 c7 = texture2D(CC_Texture1, v_texCoord + vec2(0.01, 0.01));    
        vec4 c8 = texture2D(CC_Texture1, v_texCoord + vec2(0.01, -0.01)); 

        vec4 blurColor = c0 + c1 + c2 + c3 + c4 + c5 + c6 + c7 + c8;
        blurColor /= 9.0;
        finalColor = texColor + blurColor * (1.0 - texColor.a); 
    }
    gl_FragColor    = v_fragmentColor * finalColor;                                         
}   