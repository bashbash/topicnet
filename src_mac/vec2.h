/*
 *  vec2.h
 *  topicNet
 *
 *  Created by basak alper on 12/15/10.
 *  Copyright 2010 ucsb. All rights reserved.
 *
 */

#ifndef VEC2_H
#define VEC2_H

#include <math.h>

/*
 IEEE 754 Specification:
 
 Size(bits):						32			64
 Usual C implementation:			float		double
 Sign(bits):						1			1
 Exponent(bits):					8			11
 Significand/Mantissa(bits):		23			52
 Range:							+/-10^38	+/-10^308
 Smallest absolute value:		10^-38		10^-308
 Precision						1 in 10^6	1 in 10^15
 
 */

#ifndef ABS
#define ABS(x) ((x)<0?-(x):(x))
#endif

#define VEC2_RAD2DEG (57.29577951308)

/*!
 \class Vec2
 
 A 2D vector class.  Contains overloaded operators for the usual arithmetic operations as well
 as a range of instance and static functions for other vector math operations.  Static methods may
 seem redundant, but they are useful when operating on buffers of numbers, which can be cast to
 Vec2 type.
 */
template <typename T = double>
class Vec2 {
public:
	// 2-component vector
	T x, y;
	
	Vec2()
	: x(0), y(0)
	{}
	
	Vec2(T *v) {set(v);}
	
	Vec2(T x, T y)
	: x(x), y(y)
	{}
	
	template <typename T2>
	Vec2(Vec2<T2> &v) {
		x = (T)v.x;
		y = (T)v.y;
	
	}
	
	Vec2(const Vec2 &v)
	{ x = v.x; y = v.y; }
	
	T& operator[](int i)		{ return ((T *)&x)[i]; }
	T  operator[](int i) const	{ return ((T *)&x)[i]; }
	operator const T*()			{ return (T *)&x; }
	
	T* ptr() { return (T *)&x; }
	
	void set(const Vec2 &v)
	{ x = v.x; y = v.y;}
	
	void set(T *v)
	{ T *vv = &x; *vv++ = *v++; *vv++ = *v++; }
	
	void set(T x, T y)
	{this->x = x; this->y = y; }
	
	/*! Negation */
	const Vec2 operator- () const {
		return Vec2(-x, -y );
	}
	
	/*! Subtraction */
	const Vec2 operator- (const Vec2 &v) const {
		return Vec2(x-v.x, y-v.y);
	}
	
	/*! Addition */
	const Vec2 operator+ (const Vec2 &v) const {
		return Vec2(x+v.x, y+v.y);
	}
	
	/*! Scale */
	const Vec2 operator* (T s) const {
		return Vec2(x*s, y*s);
	}
	
	/*! Scalar Divide */
	const Vec2 operator/ (T s) const {
		double sinv = 1./s;
		return Vec2(x*sinv, y*sinv);
	}
	
	/*! Multiply */
	const Vec2 operator* (const Vec2 v) const {
		return Vec2(x*v.x, y*v.y);
	}
	
	/*! Divide */
	const Vec2 operator/ (const Vec2 &v) const {
		return Vec2(x/v.x, y/v.y);
	}
	
	
	
	/*! In-place Constant Addition */
	Vec2 &operator+= (T s) {
		x += s; y += s; 
		return *this;
	}
	
	/*! In-place Constant Subtraction */
	Vec2 &operator-= (T s) {
		x -= s; y -= s; 
		return *this;
	}
	
	/*! In-place Addition */
	Vec2 &operator+= (Vec2 v) {
		x += v.x; y += v.y; 
		return *this;
	}
	
	/*! In-place Subtraction */
	Vec2 &operator-= (Vec2 v) {
		x -= v.x; y -= v.y; 
		return *this;
	}
	
	/*! In-place Scale */
	Vec2 &operator*= (T s) {
		x *= s; y *= s; 
		return *this;
	}
	
	/*! In-place Multiply */
	Vec2 &operator*= (Vec2 v) {
		x *= v.x; y *= v.y; 
		return *this;
	}
	
	/*! is Equal
	 @param v1	First input
	 @param v2	Second input
	 */
	static bool isEqual(Vec2 &v1, Vec2 &v2) {
		if(v1.x == v2.x && v1.y == v2.y ){
			return true;
		}
		return false;
	}
	
	/*! Addition
	 
	 @ret v	Result
	 @param v1	First input
	 @param v2	Second input
	 */
	static void add(Vec2 &v, Vec2 &v1, Vec2 &v2) {
		v.x = v1.x + v2.x;
		v.y = v1.y + v2.y;
	}
	
	/*! Subtraction
	 
	 @ret v	Result
	 @param v1	First input
	 @param v2	Second input
	 */
	static void sub(Vec2 &v, Vec2 &v1, Vec2 &v2) {
		v.x = v1.x - v2.x;
		v.y = v1.y - v2.y;
	}
	
	/*! Component-wise Multiply
	 
	 @ret v	Result
	 @param v1	First input
	 @param v2	Second input
	 */
	static void mul(Vec2 &v, Vec2 &v1, Vec2 &v2) {
		v.x = v1.x * v2.x;
		v.y = v1.y * v2.y;
	}
	
	/*! Component-wise Divide
	 
	 @ret v	Result
	 @param v1	First input
	 @param v2	Second input
	 */
	static void div(Vec2 &v, Vec2 &v1, Vec2 &v2) {
		v.x = v1.x / v2.x;
		v.y = v1.y / v2.y;
	}
	
	/*! Scale
	 
	 @ret v	Result
	 @param v1	First input
	 @param s	Scale factor
	 */
	static void scale(Vec2 &v, Vec2 &v1, T s) {
		v.x = v1.x * s;
		v.y = v1.y * s;
	}
	
	/*! Dot product
	 
	 @ret dot product
	 @param v1	First input
	 @param v2	Second input
	 */
	static float dot(const Vec2 &v1, const Vec2 &v2) {
		float result = v1.x * v2.x;
		result += v1.y * v2.y;
		return result;
	}
	
	/*! Magnitude squared
	 
	 @ret magnitude squared
	 @param v	Input vector
	 */
	static float mag_sqr(const Vec2 &v) {
		return dot(v, v);
	}
	
	/*! Magnitude
	 
	 @ret magnitude
	 @param v	Input vector
	 */
	static float mag(const Vec2 &v) {
		return sqrt(dot(v, v));
	}
	
	/*! Cross product
	 
	 @ret cross double
	 @param v1	First input
	 @param v2	Second input
	 */
	static void cross(const Vec2 &v1, const Vec2 &v2) {
		
		//return Vector2D(v.Y, -v.X);
		return (v1.x*v2.y) - (v1.y*v2.x);
	}
	
	
	/*! Normalize
	 
	 @param v	Vector to normalize
	 */
	static void normalize(Vec2 &v) {
		float magnitude_sqr = Vec2::dot(v, v);
		
		if (magnitude_sqr > FLOAT_EPS) {
			float scale = sqrt(magnitude_sqr);
			scale = 1.0f / scale;
			v.x *= scale;
			v.y *= scale;
		}
		else {
			v.x = FLOAT_EPS;
			v.y = FLOAT_EPS;
		}
	}
	
	/*! Linear Interpolation
	 
	 @ret v		Result
	 @param v1		First input
	 @param v1		Second input
	 @param interp	Interpolation factor [0, 1]
	 */
	static void lerp(Vec2 &v, Vec2 &v1, Vec2 &v2, T interp) {
		v.x = v1.x + interp*(v2.x - v1.x);
		v.y = v1.y + interp*(v2.y - v1.y);
	}
	
	
	static Vec2 easein2(Vec2 &v1, Vec2 &v2, T t) {
		return (v2-v1)*t*t+v1;
	}
	
	static Vec2 easeout2(Vec2 &v1, Vec2 &v2, T t) {
		return -(v2-v1)*t*(t-2)+v1;
	}
	
	static Vec2 easeinout2(Vec2 &v1, Vec2 &v2, T t) {
		t *= 2.;
		if(t < 1.) {
			return (v2-v1)*0.5*t*t+v1;
		}
		else {
			T amt = t-2;
			return -(v2-v1)*0.5*(amt*amt-2.)+v1;
		}
	}
	
	/*
	 function cubic_in(t, b, c, d)
	 local amt = t/d
	 return c*amt*amt*amt+b
	 end
	 
	 function cubic_out(t, b, c, d)
	 local amt = t/d-1
	 return c*(amt*amt*amt+1)+b
	 end
	 
	 function cubic_inout(t, b, c, d)
	 t = t*2/d
	 if(t < 1) then
	 return c/2*t*t*t+b
	 else
	 local amt = t-2
	 return c/2*(amt*amt*amt+2)+b
	 end
	 end
	 
	 function quartic_in(t, b, c, d)
	 return c*pow(t/d, 4)+b
	 end
	 
	 function quartic_out(t, b, c, d)
	 return -c*(pow(t/d-1, 4)-1)+b
	 end
	 
	 function quartic_inout(t, b, c, d)
	 t = t*2
	 if(t < 1.) then
	 return c/2*pow(t/d, 4)+b
	 else
	 return -c/2*(pow(t-2, 4)-2)+b
	 end
	 end
	 */
	
	static void bezier(Vec2 &v, Vec2 &p1, Vec2 &p2, Vec2 &p3, Vec2 &p4, float mu) {
		T mum1 = 1. - mu;
		T mum13 = mum1 * mum1 * mum1;
		T mu3 = mu * mu * mu;
		
		v.x = mum13*p1.x + 3*mu*mum1*mum1*p2.x + 3*mu*mu*mum1*p3.x + mu3*p4.x;
		v.y = mum13*p1.y + 3*mu*mum1*mum1*p2.y + 3*mu*mu*mum1*p3.y + mu3*p4.y;
	}
	
	
	
	/*
	 de casteljau algorithm for four point interpolation 
	 @ret v result
	 @param a		First point
	 @param b		Second point
	 @param c		Third point
	 @param d		Fourth point
	 @param interp	Interpolation factor [0, 1]
	 
	 */
	static void casteljau(Vec2 &v, Vec2 &a, Vec2 &b, Vec2 &c, Vec2 &d, T interp){
		Vec2 ab,bc,cd,abbc,bccd;
		lerp (ab, a,b,interp);           // point between a and b 
		lerp (bc, b,c,interp);           // point between b and c 
		lerp (cd, c,d,interp);           // point between c and d 
		lerp (abbc, ab,bc,interp);       // point between ab and bc 
		lerp (bccd, bc,cd,interp);       // point between bc and cd 
		lerp (v, abbc,bccd,interp);		 // point on the curve 
		
	}
	
	/*
	 hermite curve interpolation 
	 @ret v result
	 @start point p1
	 @start tangent t1 (direction and velocity at the start point)
	 @end point p2
	 @end tangent t2,
	 @param interp	Interpolation factor [0, 1]
	 
	 */
	static void hermite(Vec2 &v, Vec2 &p1, Vec2 &t1, Vec2 &p2, Vec2 &t2, T interp){
		T interpSq = interp*interp;
		T interpCb = interpSq*interp;
		
		// calculate basis functions
		T h1 = 2*interpCb - 3*interpSq + 1;
		T h2 = -2*interpCb + 3*interpSq;
		T h3 = interpCb - 2*interpSq + interp;
		T h4 = interpCb - interpSq;
		
		// multiply and sum all funtions together to build the interpolated point along the curve.
		v = p1*h1 + p2*h2 + t1*h3 + t2*h4;
	}
	
	static void hermite2(Vec2 &v, Vec2 &p0, Vec2 &p1, Vec2 &p2, Vec2 &p3, T mu/*interp*/, T tension=0, T bias=0) {
		T mu2 = mu * mu;
		T mu3 = mu2 * mu;
		
		T a0 =  2*mu3 - 3*mu2 + 1;
		T a1 =    mu3 - 2*mu2 + mu;
		T a2 =    mu3 -   mu2;
		T a3 = -2*mu3 + 3*mu2;
		
		T k1 = (1+bias)*(1-tension)*0.5;
		T k2 = (1-bias)*(1-tension)*0.5;
		
		Vec2 m0  = (p1-p0)*k1;
		m0 += (p2-p1)*k2;
		
		Vec2 m1  = (p2-p1)*k1;
		m1 += (p3-p2)*k2;
		
		v = p1*a0 + m0*a1 + m1*a2 + p2*a3;
	}
	
	
		
	/*! Centroid of a triangle defined by three points
	 @param p1	Point1
	 @param p2	Point2
	 @param p3	Point3
	 @ret c	Centroid
	 */
	static void centroid3(Vec2 &c, const Vec2 &p1, const Vec2 &p2, const Vec2 &p3) {
		c.x = 0.333333*(p1.x+p2.x+p3.x);
		c.y = 0.333333*(p1.y+p2.y+p3.y);
	}
	
		
	/*! Minimum
	 */
	static Vec2 vmin(const Vec2 &v1, const Vec2 &v2) {
		Vec2 rv;
		rv.x = (v1.x > v2.x) ? v2.x : v1.x;
		rv.y = (v1.y > v2.y) ? v2.y : v1.y;
		return rv;
	}
	
	/*! Maximum
	 */
	static Vec2 vmax(const Vec2 &v1, const Vec2 &v2) {
		Vec2 rv;
		rv.x = (v1.x < v2.x) ? v2.x : v1.x;
		rv.y = (v1.y < v2.y) ? v2.y : v1.y;
		return rv;
	}
	
	/*! Modulo
	 */
	static Vec2 mod(const Vec2 &v, T m) {
		Vec2 rv;
		rv.x = fmod(v.x, m);
		rv.y = fmod(v.y, m);
		return rv;
	}
	
	/*! Quantize
	 */
	static Vec2 quantize(const Vec2 &v, T q) {
		Vec2 rv;
		rv.x = (v.x < 0.) ? (v.x - (q + fmod(v.x, q))) : (v.x - fmod(v.x, q));
		rv.y = (v.y < 0.) ? (v.y - (q + fmod(v.y, q))) : (v.y - fmod(v.y, q));
		return rv;
	}
	
	static T angle(const Vec2 &v1, const Vec2 &v2) {
		return acos(dot(v1, v2));
	}
	
	static Vec2 slerp(const Vec2 &v1, const Vec2 &v2, T amt) {
		T theta = Vec2::angle(v1, v2);
		T c1 = sin((1-amt)*theta)/sin(theta);
		T c2 = sin(amt*theta)/sin(theta);
		
		return v1*c1 + v2*c2;
	}
	
	static Vec2 line_intersect_2d(Vec2 &p1, Vec2 &p2, Vec2 &p3, Vec2 &p4) {
		Vec2 v;
		
		float p1p2 = p1.x*p2.y - p1.y*p2.x;
		float p3p4 = p3.x*p4.y - p3.y*p4.x;
		float denom = (p1.x - p2.x)*(p3.y - p4.y) - (p1.y - p2.y)*(p3.x - p4.x);
		
		v.x =	p1p2*(p3.x - p4.x) - (p1.x - p2.x)*p3p4;		
		v.y =	p1p2*(p3.y - p4.y) - (p1.y - p2.y)*p3p4;
		
		v.x /= denom;
		v.y /= denom;
		
		
		return v;
	}
	
};

typedef Vec2<float> vec2f;
typedef Vec2<double> vec2d;
	


#endif	// Vec2_H
