##! Conway's Game of Life implemented in the Bro programming language.
##!
##! Author: Seth Hall <seth@icir.org>

@load frameworks/communication/listen

module ConwaysGameOfLife;

export {
	## The length of time between each generation.
	const generation_life = .001sec &redef;
}

type Field: record {
	field: vector of bool;
	seed_field: vector of bool &optional;
	generation: count &default=0;
	x: count;
	y: count;
};

global initialize_board: function(): vector of bool;

const iter3=set(-1,0,1);
const looper="this is an arbitrary string that is used for looping. it just needs to be nice and long to accomodate the maximum length someone might use on an axis of their field.";

global stdout = open("/dev/stdout") &raw_output;

function draw_field(f: Field)
	{
	# Reset the cursor to the zero position but don't clear
	# the screen.  Clearing the screen gives a tearing effect.
	print stdout, "\033[0;0H";

	print fmt("==== Generation: %d ====", f$generation);

	local i = 0;
	local background = "\xf0\x9f\x8c\xb1";
	for ( y in looper )
		{
		local j = 0;
		local field_line="";
		for ( x in looper )
			{
			local cell = f$x*i+j;
			#field_line += (f$field[cell]) ? "\xf0\x9f\x92\xa9" : ".";
			print stdout, (f$field[cell]) ? "\xf0\x9f\x92\xa9" : background;
			if ( ++j == f$x )
				break;
			}
		#print field_line;
		print stdout, "\n";
		if ( ++i == f$y )
			break;
		}
	}

function count_alive(f: Field, i: count, j: count): count
	{
	local ret=0;

	for ( a in iter3 )
		{
		local x: int = i+a;
		for ( b in iter3 )
			{
			local y: int = j+b;
			if ( x==i && y==j )
				next;
			if ( y < f$y && x < f$x &&
			     x >= 0 && y >= 0)
				{
				ret += f$field[f$x*y+x] ? 1:0;
				}
			}
		}
	return ret;
	}

function evolve(f: Field): Field
	{
	local i = 0;
	local alive = 0;
	local tmp_field = copy(f$field);
	for ( x in looper )
		{
		local j = 0;
		for ( y in looper )
			{
			alive = count_alive(f, i, j);
			local cell = f$x*j+i;
			local cs = f$field[cell];
			if ( cs )
				{
				if ( (alive > 3) || ( alive < 2 ) )
					tmp_field[cell] = F;
				else
					tmp_field[cell] = T;
				} 
			else 
				{
				if ( alive == 3 )
					tmp_field[cell] = T;
				else
					tmp_field[cell] = F;
				}
			++j;
			if ( j == f$y )
				break;
			}
		++i;
		if ( i == f$x )
			break;
		}
	f$field = tmp_field;
	return f;
	}

event loop_event(f: Field)
	{
	draw_field(f);
	++f$generation;
	if ( !any_set(f$field) )
		print "Extinction!";
	else
		schedule generation_life { loop_event(evolve(f)) };
	}

function run(f: Field)
	{
	if ( f$x*f$y != |f$field| )
		{
		Reporter::error("Your 'Game of Life' field is not laid out correctly.");
		return;
		}

	f$seed_field = copy(f$field);
	event loop_event(f);
	}

function initialize_board(): vector of bool
	{
	return vector(
	F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,T,F,F,F,F,F,F,F,F,F,F,F,
	F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,T,F,T,F,F,F,F,F,F,F,F,F,F,F,
	F,F,F,F,F,F,F,F,F,F,F,F,T,T,F,F,F,F,F,F,T,T,F,F,F,F,F,F,F,F,F,F,F,F,T,T,
	F,F,F,F,F,F,F,F,F,F,F,T,F,F,F,T,F,F,F,F,T,T,F,F,F,F,F,F,F,F,F,F,F,F,T,T,
	T,T,F,F,F,F,F,F,F,F,T,F,F,F,F,F,T,F,F,F,T,T,F,F,F,F,F,F,F,F,F,F,F,F,F,F,
	T,T,F,F,F,F,F,F,F,F,T,F,F,F,T,F,T,T,F,F,F,F,T,F,T,F,F,F,F,F,F,F,F,F,F,F,
	F,F,F,F,F,F,F,F,F,F,T,F,F,F,F,F,T,F,F,F,F,F,F,F,T,F,F,F,F,F,F,F,F,F,F,F,
	F,F,F,F,F,F,F,F,F,F,F,T,F,F,F,T,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,
	F,F,F,F,F,F,F,F,F,F,F,F,T,T,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,
	F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,
	F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,
	F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,
	F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,
	F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,
	F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,
	F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,
	F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,
	F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,
	F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,
	F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,
	F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,
	F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,
	F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,
	F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,
	F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,
	F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,
	F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F);
	}

event bro_init()
	{
	# Clear the screen.
	print stdout, "\033c";

	local data = initialize_board();
	ConwaysGameOfLife::run([$field=data, $x=36, $y=27]);
	}
