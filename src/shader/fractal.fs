#version 330

#define PI 3.1415926538

in vec2 position
in float acceptable_err;
in int max_trial;
out int trial;

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
	return(Complex_euler(z_1.re / z_2.re, z_1.im - z_2.im));
}
//complex multiplication
Complex_euler C_mul(Complex_euler z_1, Complex_euler z_2) {
	return(Complex_euler(z_1.re * z_2.re, z_1.im + z_2.im));
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
	Cart_ans = C_e__to__C_c(ans);
	return(C_div(C_c__to__C_e(C_sub(Cart_ans, guess)), ans));
}

float check(Complex_cartesian guess) {
	float errs[3];
    for (int i = 0; i < 3; i++) {
		errs[i] = check_err(guess, err);
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
	Complex_cartesian top = C_add(C_e__to__C_c(C_mul(Complex_euler(2, 0), C_pow(z, 3))), Complex_euler(1, 0));
	Complex_euler bottom = C_mul(Complex_euler(3, 0), C_pow(z, 2));
	return(C_div(C_c__to__C_e(top), bottom));
}

void main() {
	Complex_cartesian z = Complex_cartesian(position.x, position.y);
	int trials = 0;
	while (check_err(z) > acceptable_err || trials < max_trial) {
		z = optimized(z);
		trials += 1;
	}
	trial = trials;
}