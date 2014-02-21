package
{
	//--------------------------------------
	// SCRIPTS for int 64-bit cases
	//--------------------------------------

	public class INT64
	{
		public function al(v:uint):i64 { var o:i64 = new i64();  o.l = v; return o; }	// +assign 32-bit value
		public function ax(h:uint, l:uint):i64 { var o:i64 = new i64();  o.h = h; o.l = l; return o; }	// +assign 64-bit v.as 2 regs
		public function v(v:uint):i64 { var o:i64 = new i64();  o.l = v; return o; }	// +assign 32-bit value
		public function c(a:i64):i64 { var o:i64 = new i64(); o.h = a.h; o.l = a.l; return o; }	// clone	
		public function clone(a:i64):i64 { return this.c(a); }	// clone object

		// for given object
		public function v_(a:i64, v:uint):void { a.h = 0; a.l = v; }
		public function al_(a:i64, v:uint):void { a.h = 0; a.l = v; }
		public function ax_(a:i64, h:uint, l:uint):void { a.h = h; a.l = l; }	
		
		/* Type conversions */

		public function toNumber(a:i64):Number	// value=2^53
		{ var u:Number = a.l; if (a.h > 0) u += (a.h * 0x100000000); return u; }

		public function s(s:String):i64
		{
		var o:i64 = new i64(); var a:int = s.indexOf("0x");
		if (a < 0) trace("fromString error");
		else { o.h = parseInt("0x" + s.substr(a + 2, 8), 16); o.l = parseInt("0x" + s.substr(a + 10, 8), 16); }	// +assign by string
		return o;
		}	// +assign by string
		public function fromString(s:String):i64 { return this.s(s); }

		public const one:i64 = al(1);
		public const MIN_VALUE:i64 = ax(0,0);
		public const MAX_VALUE:i64 = ax(0xFFFFFFFF, 0xFFFFFFFF);
		
		public const pw10:Array = [ ax(0,0x1), ax(0,0xA), ax(0,0x64), ax(0,0x3E8), ax(0,0x2710),
			ax(0,0x186A0), ax(0,0xF4240), ax(0,0x989680), ax(0,0x5F5E100), ax(0,0x3B9ACA00),
			ax(0x2, 0x540BE400), ax(0x17, 0x4876E800), ax(0xE8, 0xD4A51000), ax(0x918, 0x4E72A000),
			ax(0x5AF3, 0x107A4000), ax(0x38D7E, 0xA4C68000), ax(0x2386F2, 0x6FC10000),
			ax(0x1634578, 0x5D8A0000), ax(0xDE0B6B3,0xA7640000), ax(0x8AC72304,0x89E80000) ];
		
		public function and(a:i64, b:i64):i64 { var o:i64 = new i64();  o.h = a.h & b.h; o.l = a.l & b.l; return o; }
		public function or(a:i64,b:i64):i64 { var o:i64 = new i64();  o.h = a.h | b.h; o.l = a.l | b.l; return o; }
		public function xor(a:i64,b:i64):i64 { var o:i64 = new i64();  o.h = a.h ^ b.h; o.l = a.l ^ b.l; return o; }
		public function not(a:i64):i64 { var o:i64 = new i64();  o.h = ~a.h; o.l = ~a.l; return o; }

		// for given object
		public function and_(a:i64, b:i64):void { a.h &= b.h; a.l &= b.l; }
		public function or_(a:i64, b:i64):void { a.h |= b.h; a.l |= b.l; }
		public function xor_(a:i64, b:i64):void { a.h ^= b.h; a.l ^= b.l; }
		public function not_(a:i64):void { a.h = ~a.h; a.l = ~a.l; }
		
		public function toString(a:i64):String
		{
		var s1:String=(a.l).toString(16);
		var s2:String=(a.h).toString(16);
		var s3:String="0000000000000000";
		s3=s3.substr(0,16-s1.length)+s1;
		s3=s3.substr(0,8-s2.length)+s2+s3.substr(8);
		return "0x"+s3.toUpperCase();
		}
		
		/* Simple Math-functions */
		
		// just to add, not rounded for overflows
		public function add(a:i64,b:i64):i64
		{
		var o:i64 = new i64();
		var l:Number = a.l + b.l;
		var h:Number = a.h + b.h;
		o.h = uint(h) + (l>0xFFFFFFFF?1:0);
		o.l = uint(l);
		return o;
		}

		// verify a>=b before usage
		public function sub(a:i64,b:i64):i64
		{
		var o:i64 = new i64();
		var h:Number = a.h - b.h;
		var l:Number = a.l - b.l;
		o.h = uint(h) - (l<0?1:0);
		o.l = uint(l);
		return o;
		}

		// x n-times, better not to use for large n
		public function txmul(a:i64,n:int):i64
		{ var o:i64 = new i64(); o.l = a.l; o.h = a.h;
		for(var i:int=1; i<n; i++ ) o = add(o,a); return o; }

		// multiplication arithmetic
		// (it gives small mistake without checksum for too large numbers)
		public function mul(a:i64,b:i64):i64
		{
		/*
		// slow but working checksum to get right result
		if(bithighestat(a)+bithighestat(b)>63)
		{
		return bitmul(a,b);
		}
		*/

		var o:i64 = new i64();	
		var h:Number = (a.h * b.l)+ (b.h * a.l);
		var l:Number = (a.l * b.l);
		var oC:uint = ( l>0xFFFFFFFF ? l/0x100000000 : 0 );

		// the same as ( & 0xFFFFFFFF )
		o.l = uint(l);
		o.h = uint(h) + oC;
		
		return o;
		}

		// multiplication by shifting bits, good for few-bits manipulation
		// (slow)
		public function bitmul(a:i64,b:i64):i64
		{
		var o:i64 = new i64();
		var m:i64 = this.c(b);
		var t:i64 = this.c(a);
		for(var j:int=63; j>0; j--)
			{
			if( (m.l | m.h)==0 ) break; 
			if((m.l & 1)!=0) o = add(o,t);
			m = rshift(m,1);
			t = lshift(t,1);
			}
		o.l =(o.l & 0xFFFFFFFF);
		o.h =(o.h & 0xFFFFFFFF);
		return o;
		}

		// bitwise division calculates and returns [rs,rm],
		// where a=(b*rs)+rm, better not to use for simple math
		public function bitdiv(a:i64,b:i64):Array
		{
		var rs:i64 = new i64();
		var rm:i64 = this.c(a);

		if( ((b.l | b.h)!=0) && gt(a,b) )
			{
			var d:i64 = this.c(b);
			var p:i64 = this.c(d);
			var y:int = 0;
			var w:int = bithighestat(d);
			while((w<64) && ((d.l | d.h)!=0) && le(d,rm) )
				{
				p = this.c(d);
				var hbit:int=bithighestat(d);
				d = lshift(d,1);
				y++; w++;
				}

			while( (y>0) || (p.l | p.h)!=0 )
				{
				rs=lshift(rs,1); y--;
				if( le(p,rm) ) { rm=sub(rm,p); rs.l=(rs.l|1); }
				if( (y<=0) && gt(b,rm) ) break;
				p = rshift(p,1);
				}
			}
		return [rs,rm];
		}

		// x n-times multiplied by self, slow
		public function txpow(a:i64,n:int):i64
		{ var o:i64 = this.c(a);
		for (var i:int = 1; i < n; i++ )
			{
				if (i == 31)
					{
					var q:int = 0;
					}
				
				o = mul(o, a);
			}
		return o; }

		/* Bit-shifting */
		
		public function lshift(a:i64,n:int):i64
		{
		var o:i64 = new i64();	
		switch(n)
		{
		case 0: { o.h = a.h; o.l = a.l; break; };
		case 32: { o.h = a.l; break; }
		default:
		{ if (n < 32) { o.h = (a.h << n) + (a.l >>> (32 - n)); o.l = (a.l << n); }
		else { o.h = (a.l << (n - 32)); }; break; }
		}
		return o;
		}

		public function rshift(a:i64,n:int):i64
		{
		var o:i64 = new i64();	
		switch(n)
		{
		case 0: { o.h = a.h; o.l = a.l; break; };
		case 32: { o.l = a.h; break; };
		default:
		{ if (n < 32) {  o.h = (a.h >>> n); o.l = (a.l >>> n) + (a.h << (32 - n)); }
		else { o.l = (a.h >>> (n - 32)); } break; }
		}
		return o;
		}

		// gets bit at position n
		public function bitat(a:i64, n:int):int
		{ return ( (n<32) ? (a.l & (1<<n)) : (a.h & (1<<(n-32))) ); } 

		// sets bit at position n (on)
		public function bitset(a:i64, n:int):void
		{ if (n < 32) { a.l |= (1 << n); } else { a.h |= (1 << (n - 32)); } } 

		// clears bit at position n (off)
		public function bitclear(a:i64, n:int):void
		{ if (n < 32) { a.l &= (~(1 << n)); } else { a.h &= (~(1 << (n - 32))); } }

		// toggles bit at position n (on/off)
		public function bittoggle(a:i64, n:int):void
		{ if (n < 32) { a.l ^= (1 << n); } else { a.h ^= (1 << (n - 32)); } }

		/* bitwise calcs just fast as possible */

		private var bitcnt_:Array = [];	
		// calculates count of bits =[0..63]
		public function bitcount(a:i64):int
		{
		if( this.bitcnt_.length==0 )
			{
			for(var i:uint=0;i<0x10000;i++)
				{
				var c:uint=0; var o:uint=i;
				for(var k:int=0;k<32;k++) { c+=(o&1); o>>>=1; };
				this.bitcnt_[i] = c;
				}
			}
		return ( this.bitcnt_[ uint(a.l & 0xFFFF) ] + this.bitcnt_[ uint((a.l>>>16) & 0xFFFF) ] +
			this.bitcnt_[ uint(a.h & 0xFFFF) ] + this.bitcnt_[ uint((a.h>>>16) & 0xFFFF) ] );
		}

		private var bitlsb_:Array = [];		
		// finds lowest bit (position [0..63] or -1)
		public function bitlowestat(a:i64):int
		{
		if ( this.bitlsb_.length==0 )
			{
			for(var i:uint=0;i<0x10000;i++)
				{
				var c:int=-1; var o:int=i;
				for(var k:int=0;c<0 && k<32;k++) { if((o&1)!=0) c=k; o>>>=1; };
				this.bitlsb_[i] = uint(c);
				}
			}
			
		var q:uint = (a.l & 0xFFFF);
		if(q!=0) return this.bitlsb_[q];
		q = ((a.l>>>16) & 0xFFFF);
		if(q!=0) return (this.bitlsb_[q] | 16);
		q = (a.h & 0xFFFF);
		if(q!=0) return (this.bitlsb_[q] | 32);
		q = ((a.h>>>16) & 0xFFFF);
		if(q!=0) return (this.bitlsb_[q] | 48);
		return -1;
		}

		private var bithsb_:Array = [];		
		// finds highest bit (position [0..63] or -1)
		public function bithighestat(a:i64):int
		{
		if ( this.bithsb_.length==0 )
			{
			for(var i:uint=0;i<0x10000;i++)
				{
				var c:int=-1; var o:int=i; var m:uint=(1<<31);
				for(var k:int=31;c<0 && k>=0;k--) { if((o&m)!=0) c=k; m>>>=1; };
				this.bithsb_[i] = uint(c);
				}
			}

		var q:uint = ((a.h>>>16) & 0xFFFF);
		if(q!=0) return (this.bithsb_[q] | 48);
		q = (a.h & 0xFFFF);
		if(q!=0) return (this.bithsb_[q] | 32);
		q = ((a.l>>>16) & 0xFFFF);
		if(q!=0) return (this.bithsb_[q] | 16);
		q = (a.l & 0xFFFF);
		if(q!=0) return this.bithsb_[q];
		return -1;
		}

		private var bitObjat_:Array = [];		
		// returns object for a bit[0..63]
		public function bitObj(n:int):i64
		{
		if ( this.bitObjat_.length==0 )
			{
			var o:i64 = al(1);
			for(var i:int=0;i<64;i++) { this.bitObjat_[i]=this.c(o); o=lshift(o,1); }
			}
		return this.bitObjat_[n];
		}
		
		/* Comparisons */

		public function eq(a:i64,b:i64):Boolean { return ((a.h == b.h) && (a.l == b.l)); }
		public function ne(a:i64,b:i64):Boolean { return ((a.h != b.h) || (a.l != b.l)); }
		public function gt(a:i64,b:i64):Boolean { return ((a.h > b.h) || ((a.h == b.h) && (a.l >  b.l))); }
		public function ge(a:i64,b:i64):Boolean { return ((a.h > b.h) || ((a.h == b.h) && (a.l >= b.l))); }
		public function lt(a:i64,b:i64):Boolean { return ((a.h < b.h) || ((a.h == b.h) && (a.l <  b.l))); }
		public function le(a:i64,b:i64):Boolean { return ((a.h < b.h) || ((a.h == b.h) && (a.l <= b.l))); }

		/* Decimal conversions */

		// converts to decimal string
		public function todecString(a:i64):String
		{
		var s:String=""; var rz:Array =[ new i64(), this.c(a) ];
		for(var n:int=19;n>=0;n--)
			{
			rz=bitdiv(rz[1],this.pw10[n]); var d:uint=rz[0].l;
			if((n==0 && (s.length==0)) || (d>0) || (s.length>0)) s+=d.toString();
			}
		return s;
		}

		// converts decimal String to 64-bit object
		public function fromdecString(s:String):i64
		{
		var o:i64 = new i64();
		var c:int =s.length;
		for(var n:int=0;(n<=19) && ((c--)>0);n++)
			{
			var d:int=s.charCodeAt(c)-48;
			if((d>0) && (d<=9))
				{
				var o2:i64=bitmul(this.pw10[n],al(d)); o=add(o,o2);
				}
			}
		return o;
		}
		
		/* Other basic functions */

		public function max(a:i64,b:i64):i64 { return (ge(a,b) ? a : b ); }	// max
		public function min(a:i64,b:i64):i64 { return (le(a,b) ? a : b ); }	// min
		public function neg(a:i64):i64   { return add(not(a),this.one); }	// negative value as unsigned
		public function mod(a:i64,b:i64):i64 { var rz:Array=bitdiv(a,b); return rz[1]; }	// modulus
		public function isodd(a:i64,b:i64):Boolean { return ((a.l&1)==0); }	// is odd
		public function next(a:i64):i64 { return add(a,this.one); }		// next number
		public function pre(a:i64):i64 { return sub(a,this.one); }		// previous number
		public function is0(a:i64):Boolean { return ((a.l | a.h)==0); }		// is zero?
		public function not0(a:i64):Boolean { return ((a.l | a.h)!=0); }	// not zero?
		
		// fast if can do it, otherwise reminder contains unprocessed value
		public function primesIfCan(a:i64):Array	// returns  array [ [primes a=a1*a2*...*an], reminder object ]
		{
		var ret:Array=[]; var k:int=0;
		var rz:Array=[ new i64(), this.c(a) ];
		const primes:Array=[2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97];
		var o:i64=rz[1];
		for(var i:int=0; ((o.l | o.h)!=0) && i<primes.length;)
			{
			var o2:i64=al(primes[i]); var op:i64=this.c(o);
			rz=bitdiv(o,o2); o=rz[1];
			if((o.l | o.h)==0)  { ret[k++]=o2; o=rz[0]; }
			else { i++; o=op; }
			if( eq(o,o2) ) { ret[k++]=o2; o=al(0); }
			}
		return [ret,o];
		}

		//--------------------------------------
		// END OF SCRIPTS for int 64-bit cases
		//--------------------------------------

	}	
}