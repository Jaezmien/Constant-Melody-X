/*********************************************************
* "Image Cel Shade" by Shadertoy user simonbodeus (heavily stripped down)
* 
* Pass RGB color to HSV then posterize the Saturation and Value components before repass modified HSV to RGB colors.
* Posterize directly RGB(right image) values gives a bad result with color banding particulary with low colors values
*********************************************************/
#version 130

varying vec2 imageCoord;
uniform vec2 textureSize;
uniform vec2 imageSize;
uniform sampler2D sampler0;

vec2 img2tex( vec2 v ) { return v / textureSize * imageSize; }

float nColors =4.0;

void main()
{ 
	vec2 uv = imageCoord.xy;
   	vec3 tc = texture(sampler0, img2tex(uv)).rgb;
    vec2 coord = vec2(0.,0.);
    
    float cutColor = 1./nColors;
     
   	tc  = cutColor*floor(tc/cutColor);
    
    gl_FragColor = vec4(tc, 1.0);
   
}