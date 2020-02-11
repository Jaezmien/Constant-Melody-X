uniform float amount;

varying vec4 color;
varying vec2 imageCoord;
uniform vec2 resolution;
uniform vec2 textureSize;
uniform vec2 imageSize;
uniform sampler2D sampler0;

vec2 img2tex( vec2 v )
{
	return v / textureSize * imageSize;
}

float normpdf( in float x, in float sigma )
{
	return 0.39894 * exp(-0.5 * x * x / pow(sigma,2.0)) / sigma;
}

void main()
{
	vec2 uv = imageCoord;
	vec3 col = texture2D( sampler0, img2tex(uv) ).rgb;

	if ( amount > 0.0 )
	{
		const int mSize = 10;
		const int kSize = (mSize - 1) / 2;
		float kernel[mSize];

		for (int i = 0; i <= kSize; ++i)
		{
			kernel[kSize+i] = kernel[kSize-i] = normpdf(float(i), amount);
		}

		col = vec3(0.0);
		float z = 0.0;

		for (int i = -kSize; i <= kSize; ++i)
		{
			for (int j = -kSize; j <= kSize; ++j)
			{
				vec2 p = mod( uv + vec2(float(i), float(j)) / resolution, 1.0 );
				vec3 c = texture2D( sampler0, img2tex(p) ).rgb;

				float factor = kernel[kSize+i] * kernel[kSize+j];
				z += factor;
				col += factor * c;
			}
		}

		col /= z;
	}

	gl_FragColor = vec4( col, 1.0 ) * color;
}
