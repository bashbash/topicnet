uniform vec4 haloColor;
uniform sampler2D profile;
uniform sampler2D texture;

varying vec4 Diffuse;
varying vec3 upVec;
varying vec3 sideVec;
varying vec3 coord;
varying vec2 depth0;
varying vec2 depth1;

void main (void)
{
	vec2 tcd = coord.xy;
	tcd.x = (coord.x / coord.z) * 0.5 + 0.5;
	if (tcd.x < 0.0 || tcd.x > 1.0)
	{
		// we are outside of the actual streamline position on the horizontal, and thus need to draw the halo
		
		// pixel color is set to the color of the halo
	    gl_FragColor = haloColor;
	    
	    // pixel depth is set to that of the actual extruded quad (z / w)
		gl_FragDepth = (depth0.x/depth0.y) * 0.5 + 0.5;
	}
	else
	{
		// we are inside of the streamline, so generate appropriate values
		
		// use the horizontal and vertical position as texture lookup values for the streamline texture
		vec3 tex = texture2D(profile, tcd.xy).xyz;
		
		// expand x value from [0..1] to [-1..1]
		tex.x = tex.x * 2.0 - 1.0;
    
		// calculate real pixel normal as linear combination of side and upvector multiplied by x and y factor
	    vec3 norm = sideVec * tex.x - tex.y * upVec;

		// compute diffuse factor based on the normal
		float diff = clamp(dot(gl_LightSource[0].position.xyz, norm),0.0,1.0);
		
		// compute specular factor based on the normal
		float spec = pow(clamp(dot(gl_LightSource[0].halfVector.xyz, norm),0.0,1.0), gl_FrontMaterial.shininess);

		// add up factors to get the real pixel color (same as phong shading)
		gl_FragColor = diff * Diffuse * texture2D(texture, tcd.xy) + spec * gl_FrontLightProduct[0].specular + gl_FrontLightProduct[0].ambient;
    
		// calculate the pixel depth value as interpolation between quad and the quad extruded to the front
		// to generate a near correct depth value
		vec2 rdep = tex.y * depth1 + (1.0 - tex.y) * depth0;
		
		// depth is z value divided by w value
		gl_FragDepth = (rdep.x / rdep.y) * 0.5 + 0.5;
	} 
}