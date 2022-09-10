#version 330

in vec2 fragTexCoord;
in vec4 fragColor;

uniform vec2 screenDims;
uniform float acceptable_err;
uniform int max_trial;
uniform vec2 offset;
uniform float zoom;

out vec4 color;


const float PI = 3.1415926535;

struct Complex_cartesian {
	float re;
	float im;
};

struct Complex_euler {
	float radius;
	float theta;
};

//cartesian to euler
Complex_euler C_c__to__C_e(Complex_cartesian z) {
	float r = sqrt(pow(z.re, 2) + pow(z.im, 2));
	float t = atan(z.im/z.re);
	return(Complex_euler(r, t));
}
//euler to cartesian
Complex_cartesian C_e__to__C_c(Complex_euler z) {
	float a = z.radius * cos(z.theta);
	float b = z.radius * sin(z.theta);
	return(Complex_cartesian(a, b));
}
//complex addition
Complex_cartesian C_add(Complex_cartesian z_1, Complex_cartesian z_2) {
	return(Complex_cartesian(z_1.re + z_2.re, z_1.im + z_2.im));
}
//complex subtraction
Complex_cartesian C_sub(Complex_cartesian z_1, Complex_cartesian z_2) {
	return(Complex_cartesian(z_1.re - z_2.re, z_1.im - z_2.im));
}
//complex division
Complex_euler C_div(Complex_euler z_1, Complex_euler z_2) {
	return(Complex_euler(z_1.radius / z_2.radius, z_1.theta - z_2.theta));
}
//complex multiplication
Complex_euler C_mul(Complex_euler z_1, Complex_euler z_2) {
	return(Complex_euler(z_1.radius * z_2.radius, z_1.theta + z_2.theta));
}
//complex powers
Complex_euler C_pow(Complex_euler z, float power) {
	return(Complex_euler(pow(z.radius, power), z.theta * power));
}

//absolute answers
const Complex_euler z_1 = Complex_euler(1, 0);
const Complex_euler z_2 = Complex_euler(1, 2.0*PI/3.0);
const Complex_euler z_3 = Complex_euler(1, 4.0*PI/3.0);
const Complex_euler answers[3] = Complex_euler[3](z_1, z_2, z_3);

float check_err(Complex_cartesian guess, Complex_euler ans) {
	Complex_cartesian Cart_ans = C_e__to__C_c(ans);
	return(C_div(C_c__to__C_e(C_sub(Cart_ans, guess)), ans).radius);
}

float check(Complex_cartesian guess) {
	float errs[3];
    for (int i = 0; i < 3; i++) {
		errs[i] = check_err(guess, answers[i]);
    }
	//really cool sort 2.0
	if (errs[1] > errs[2]) {
		errs[1] = errs[2];
	}
	if (errs[0] > errs[1]) {
		errs [0] = errs[1];
	}
	return(errs[0]);
}

Complex_euler optimized(Complex_euler z) {
	//2z^3+1 / 3*z^2
	Complex_cartesian top = C_add(C_e__to__C_c(C_mul(Complex_euler(2, 0), C_pow(z, 3))), Complex_cartesian(1, 0));
	Complex_euler bottom = C_mul(Complex_euler(3, 0), C_pow(z, 2));
	return(C_div(C_c__to__C_e(top), bottom));
}

void main() {
	Complex_cartesian coor = Complex_cartesian((fragTexCoord.x + offset.x/screenDims.x)/zoom, (fragTexCoord.y + offset.y/screenDims.y)/zoom);
	Complex_euler z = C_c__to__C_e(coor);
	float trial = 0.0;
	while ((check(C_e__to__C_c(z)) > acceptable_err) && (trial < max_trial)) {
		z = optimized(z);
		trial += 1;
	}
	trial /= 10;
	// trial *= 10;
	color = vec4(0, 0, trial, 1);
}