$fn=100;

module m5_clearance(){
    cylinder(h=500, d=5.5, center=true);
}

module m5(){
    cylinder(h=100, d=5, center=true);
}

module edge() {
    difference() {
        cube([30,30,10]);
        translate([30,0,-1]) rotate([0,0,45]) cube([50,50,20]);
        translate([7.5, 7.5, -1]) m5();
    }
}

module fan_spacer() {
    union() {
        difference() {
            translate([-0.5, -0.5, 0]) cube([121,121,10]);
            translate([1, 1,-1]) cube([118,118,20]);
        }
        translate([0, 0, 0]) rotate([0, 0, 0]) edge();
        translate([120, 0, 0]) rotate([0, 0, 90]) edge();
        translate([0, 120, 0]) rotate([0, 0, -90]) edge();
        translate([120, 120, 0]) rotate([0, 0, 180]) edge();
        %translate([60,60, 12]) cylinder(h=25, r=60, center=true);
    }
}

module grill_spacer() {
    difference() {
        cylinder(h=10, d=10, center=true);
        m5();
    }
}