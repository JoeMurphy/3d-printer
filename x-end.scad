// PRUSA iteration3
// X ends
// GNU GPL v3
// Josef Pr?sa <josefprusa@me.com>
// Václav 'ax' H?la <axtheb@gmail.com>
// http://www.reprap.org/wiki/Prusa_Mendel
// http://github.com/prusajr/PrusaMendel

include <inc/drivetrain.scad>
include <configuration.scad>
use <bushing.scad>
use <inc/bearing-guide.scad>


module x_end_motor(){

    mirror([0, 1, 0]) {

        x_end_base([3, 3, 0, 0], thru=false);


        translate([0, -z_delta - 2, 0]) difference(){
            union(){
                translate([-13.75, -14 + z_delta / 2, 26 - z_delta / 4]) cube_fillet([17.5, 14 + z_delta, 52 + z_delta / 2], center = true, vertical=[0, 0, 3, 1.5], top=[0, 3, 6, 3], $fn=16);
                translate([-10, -34, 9]) intersection(){
                    translate([0, 0, -z_delta / 4]) cube_fillet([10, 37, 18 + z_delta / 2], center = true, vertical=[0, 0, 0, 0], top=[0, 3, 5, 3]);
                    translate([-10/2, 10, -26]) rotate([45, 0, 0]) cube_fillet([10, 60, 60], radius=2);
                }
                translate([-15, -32, 30.25]) rotate([90, 0, 0])  rotate([0, 90, 0]) nema17(places=[1, 0, 1, 1], h=10);
            }

            // motor screw holes
            translate([-15, -32, 30.25]){
                // belt hole
                translate([1, 11, 0]) cube([10, 36, 20], center = true);
                //motor mounting holes
                translate([-7.5, 0, 0]) rotate([0, 90, 0]) nema17(places=[1, 1, 0, 1], holes=true, shadow=14.5, head_drop=17.5-5, $fn=8, h=10);
            }
        }
        //smooth rod caps
        translate([-22, -10, 0]) cube([17, 2, 15]);
        translate([-22, -10, 45]) cube([17, 2, 10]);
    }
}

module x_end_base(vfillet=[3, 3, 3, 3], thru=true, len=40){
    //height and width of the x blocks depend on x smooth rod radius
    x_box_height = 52 + 2 * bushing_xy[0];
    x_box_width = (bushing_xy[0] <= 4) ? 17.5 : bushing_xy[0] * 2 + 9.5;

    difference(){
        union(){
            translate([-10 - bushing_xy[0], -10 + len / 2, 30]) cube_fillet([x_box_width, len, x_box_height], center=true, vertical=vfillet, top=[5, 3, 5, 3]);

            translate([0, 0, 4 - bushing_xy[0]]) {
                translate([z_delta, 0, 0]) linear(bushing_z, x_box_height);
                // Nut trap
                translate([-2, 17, 4]) cube_fillet([20, 16, 8], center = true, vertical=[6, 0, 0, 0], $fn=4);
            }
        }
        // here are bushings/bearings
        translate([z_delta, 0, 4 - bushing_xy[0]]) linear_negative(bushing_z, x_box_height);

        // belt hole
        translate([-5.5-10+1.5, 22-9, 30]) cube([x_idler_width + 1, 55, 27], center = true);
	
	// Rod holes
        translate([-10 - bushing_xy[0], 0, 0]) {
            if(thru == true){
                translate([0, -11, 6]) rotate([-90, 0, 0]) pushfit_rod(bushing_xy[0] * 2 + 0.2, 50);
                translate([0, -11, xaxis_rod_distance+6]) rotate([-90, 0, 0]) pushfit_rod(bushing_xy[0] * 2, 50);
            } else {
                translate([0, -7, 6]) rotate([-90, 0, 0]) pushfit_rod(bushing_xy[0] * 2 + 0.2, 50);
                translate([0, -7, xaxis_rod_distance+6]) rotate([-90, 0, 0]) pushfit_rod(bushing_xy[0] * 2, 50);
            }
        }
        translate([0, 0, 4 - bushing_xy[0]]) {  // m5 nut insert
                    translate([0, 17, -10]) rotate([0,0,45]){
                        cylinder_poly(h = 40, r=2.65);
                        //nut slid in
                        translate([0, 0, 12])  nut_slot_hole(type=nut_M5, h=9.2);
                    }
        }
    }
    //threaded rod
    //translate([0, 17, 0]) %cylinder(h = 70, r=2.5+0.2);
}

module x_end_idler(){
    difference() {
        x_end_base(len=45);
        // idler hole
        translate([-14, 26, 29]) rotate([0, 90, 0]) {
            idler_assy(x_idler_bearing);
            translate([0,20,0])
                cube([idler_assy_r_outer(x_idler_bearing) * 2, 40, x_idler_width + 1], center=true);
            if (x_idler_bearing[3]) {
                %translate([0, 0, -(x_idler_width / 2)]) bearing_guide_outer(x_idler_bearing);
                %translate([0, 0, x_idler_width / 2]) mirror([0, 0, 1]) bearing_guide_inner(x_idler_bearing);
            }
        }
    }
}

module pushfit_rod(diameter, length){
    cylinder(h = length, r=hole_fit( dia=diameter,$fn=30)/2, $fn=30);
    translate([0, -diameter/4, length/2]) cube([diameter, diameter/2, length], center = true);

    translate([0, -diameter/2-1.2, length/2]) cube([diameter, 1, length], center = true);
}

if (x_idler_bearing[3] > 0) {
    translate([-25, -20 - x_idler_bearing[0] / 2, 0]) {
        render() bearing_guide_inner(x_idler_bearing);
        translate([x_idler_bearing[0]+10, 0, 0])
            render() bearing_guide_outer(x_idler_bearing);
    }
}


translate([-40, 0, 0]) rotate([0, 0, -90]) x_end_idler(thru=true);
translate([30, 0, 0]) rotate([0, 0, -90]) x_end_motor();

//x_end_base([3, 3, 0, 0], thru=false);