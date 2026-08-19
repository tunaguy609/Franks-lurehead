// GREEN MACHINE STYLE OFFSHORE TROLLING LURE HEAD
// 30 mm maximum OD  |  22 mm sinker cavity
// No skirt collar/ridge — straight spigot so collar can be restarted later.
//
// Print orientation: nose down (+Z toward rear / open cavity end).
// All dimensions in millimeters.
// Lure axis is the Z axis; nose is at Z = 0.
//

$fn = 128;

// -----------------------------
// KEY DIMENSIONS
// -----------------------------
head_length       = 57;     // nose-to-rear of main head
max_diameter      = 30;     // maximum OD of head
leader_bore       = 2.5;    // through-hole for leader wire

min_wall          = 5.0;
sinker_bore       = max_diameter - 2*min_wall;  // 20 mm — egg-sinker cavity ID

// Eye pockets: flat-bottom cylindrical recesses on ±Y sides
eye_diameter      = 10.25;
eye_depth         = 2.5;
eye_z             = 43;     // axial station (from nose) to pocket centre

// Skirt spigot (extension): straight hollow tube with no collar/ridge.
extension_length  = 25;
tube_od           = 25;     // spigot outer diameter (base / straight section)
tube_id           = 21.5;   // spigot inner bore

// Internal cavity limits (measured from nose)
cavity_end        = 18;     // forward end of the sinker cavity
transition_start  = 8;      // where the leader bore starts flaring to cavity


// ============================================================
// EXTERIOR GEOMETRY
// ============================================================

// -----------------------------
// Head profile (rotated about Z)
// Points are [radius, z-height] — nose at z=0.
// Ogive shoulder widens to 30 mm OD, then holds
// that diameter to the rear face at z = head_length.
// -----------------------------
module head_profile()
{
    rotate_extrude()
        polygon([
            [ 0.0,  0.0],
            [ 3.5,  1.5],
            [ 5.6,  4.0],
            [ 7.8,  8.0],
            [10.5, 14.0],
            [13.0, 21.0],
            [14.0, 24.0],   // smooth monotonic shoulder
            [14.5, 26.0],
            [14.9, 28.0],
            [15.15,30.0],
            [15.35,32.0],
            [15.5, 34.0],
            [15.0, 37.0],   // reaches full 30 mm OD here
            [15.0, 57.0],   // hold 30 mm OD to rear face
            [ 0.0, 57.0]    // close polygon at axis
        ]);
}


// -----------------------------
// Skirt spigot with no ramp/collar.
// -----------------------------
module extension_with_ramps()
{
    translate([0, 0, head_length])
        cylinder(h=extension_length, r=tube_od / 2);
}


// Combined exterior solid
module exterior()
{
    union()
    {
        head_profile();
        extension_with_ramps();
    }
}


// ============================================================
// INTERNAL CUTS
// ============================================================

// -----------------------------
// Leader passage — continuous 2.5 mm bore from nose to rear.
// Extended by 1 mm past each end to guarantee clean cuts.
// -----------------------------
module leader_passage()
{
    translate([0, 0, -1])
        cylinder(d=leader_bore, h=head_length + extension_length + 2);
}


// -----------------------------
// Front cavity transition — tapers from the 2.5 mm leader bore
// up to the 20 mm sinker cavity over the span
// [transition_start … cavity_end].
// d1 (narrow end) is at the nose side; d2 (wide end) joins the cavity.
// -----------------------------
module cavity_transition()
{
    translate([0, 0, transition_start])
        cylinder(
            d1 = leader_bore,
            d2 = sinker_bore,
            h  = cavity_end - transition_start
        );
}


// -----------------------------
// Sinker cavity — 20 mm cylindrical void that accepts an egg sinker.
// Runs from cavity_end (18 mm from nose) through to the open rear.
// Extended by 1 mm past the rear to guarantee a clean cut.
// -----------------------------
module sinker_cavity()
{
    cavity_rear = head_length + extension_length;

    translate([0, 0, cavity_end])
        cylinder(d=sinker_bore, h=cavity_rear - cavity_end + 1);
}


// -----------------------------
// Central bore through the spigot — removes the core of the
// extension so it is a tube, not a solid rod.
// -----------------------------
module central_bore()
{
    translate([0, 0, head_length - 1])
        cylinder(d=tube_id, h=extension_length + 2);
}


// -----------------------------
// Eye pockets — flat-bottom cylindrical recesses on the ±Y sides
// of the head at axial station eye_z.
//
// For each side, rotate so the cylinder points inward (toward the axis),
// then place the open end at the outer surface.  The cylinder height of
// eye_depth + 1 mm guarantees a clean flat bottom at the correct depth.
// -----------------------------
module eye_pockets()
{
    for (side = [-1, 1])
        translate([0, side * max_diameter/2, eye_z])  // outer surface, axial station
            rotate([side * 90, 0, 0])                 // point cylinder inward
                cylinder(d=eye_diameter, h=eye_depth + 1);
}


// ============================================================
// FINAL MODEL
// ============================================================
difference()
{
    exterior();

    leader_passage();       // continuous 2.5 mm through-hole
    cavity_transition();    // flared taper from leader bore to cavity
    sinker_cavity();        // 20 mm egg-sinker void from rear
    central_bore();         // hollow core of skirt spigot
    eye_pockets();          // side recesses for doll eyes
}
