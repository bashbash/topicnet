varying vec4 Diffuse;
varying vec3 upVec;
varying vec3 sideVec;
varying vec3 coord;
varying vec2 depth0;
varying vec2 depth1;

void main(void)
{
	vec4 pos;
	vec3 norm;
	vec3 viewVec;

	// transform vertex to world space
	pos	= gl_ModelViewMatrix * gl_Vertex;

	// generate vector from camera viewpoint to our vertex
	viewVec = normalize(-pos.xyz);

	// transform tangent to world space
	norm = gl_NormalMatrix * gl_Normal;

	// calculate side and up extrusion vectors
	sideVec = normalize(cross(-pos.xyz, norm));
	upVec = normalize(cross(sideVec, norm));

	// extrude the vertex by the transferred amount in side and up direction
	pos.xyz += sideVec * gl_MultiTexCoord0.x;

	// write out position
	gl_Position = gl_ProjectionMatrix * pos;

	// determine diffuse color
	Diffuse		= gl_Color * gl_LightSource[0].diffuse;

	// transfer interpolation values for texture lookups to fragment shader (x and y texture coordinates, correct for radius)
	coord.xyz = gl_MultiTexCoord0.xzy;

	// copy over depth information

	// depth0 = real position z and w values
	depth0.xy = gl_Position.zw;

	// depth1 = front extruded depth

	// only extrude depth when we're not on a hybrid part to stop depth conflicts.

	// approximate distance from center of the streamline to the infinite cylinder (clipped to ensure that no weird things happen)
	float depth = min(1.0 / dot(upVec, -viewVec), 1.0) * abs(gl_MultiTexCoord0.x);

	// mpos is our actual position moved into direction of the viewer by the calculated depth
	vec4 mpos;
	mpos.xyz = pos.xyz + viewVec * depth;
	mpos.w = 1.0;

	// transfer front position z and w values to fragment shader
	mpos = gl_ProjectionMatrix * mpos;
	depth1.xy = mpos.zw;

	// modify upvec in tangent direction
	upVec += norm * gl_MultiTexCoord0.w;
}
