% FINUFFT1D2   1D complex nonuniform FFT of type 2 (uniform to nonuniform).
%
% c = finufft1d2(x,isign,eps,f)
% c = finufft1d2(x,isign,eps,f,opts)
%
% This computes, to relative precision eps, via a fast algorithm:
%
%    c[j] = SUM   f[k1] exp(+/-i k1 x[j])      for j = 1,...,nj
%            k1
%     where sum is over -ms/2 <= k1 <= (ms-1)/2.
%
%  Inputs:
%     x     location of nonuniform targets on interval [-3pi,3pi], length nj
%     f     complex Fourier coefficients. If a vector, length sets ms
%           (with mode ordering given by opts.modeord). If a matrix, each
%           of ntrans columns is transformed with the same nonuniform targets.
%     isign if >=0, uses + sign in exponential, otherwise - sign.
%     eps   relative precision requested (generally between 1e-15 and 1e-1)
%     opts   optional struct with optional fields controlling the following:
%     opts.debug:   0 (silent, default), 1 (timing breakdown), 2 (debug info).
%     opts.spread_debug: spreader, (no text) 1 (some) or 2 (lots)
%     opts.spread_sort:  0 (don't sort NU pts), 1 (do), 2 (auto, default)
%     opts.spread_kerevalmeth:  0: exp(sqrt()), 1: Horner ppval (faster)
%     opts.spread_kerpad: (iff kerevalmeth=0)  0: don't pad to mult of 4, 1: do
%     opts.fftw: FFTW plan mode, 64=FFTW_ESTIMATE (default), 0=FFTW_MEASURE, etc
%     opts.upsampfac:   sigma.  2.0 (default), or 1.25 (low RAM, smaller FFT)
%     opts.spread_thread:   for ntrans>1 only. 0:auto, 1:seq multi, 2:par, etc
%     opts.maxbatchsize:  for ntrans>1 only. max blocking size, or 0 for auto.
%     opts.modeord: 0 (CMCL increasing mode ordering, default), 1 (FFT ordering)
%     opts.chkbnds: 0 (don't check NU points valid), 1 (do, default)
%  Outputs:
%     c     complex column vector of nj answers at targets, or,
%           if ntrans>1, matrix of size (nj,ntrans).
%
% Notes:
%  * All available threads are used; control how many with maxNumCompThreads.
%  * The vectorized (many vector) interface, ie ntrans>1, can be much faster
%    than repeated calls with the same nonuniform points. Note that here the I/O
%    data ordering is stacked rather than interleaved. See ../docs/matlab.rst
%  * For more details about the opts fields, see ../docs/opts.rst
%  * See ERRHANDLER, VALID_* and FINUFFT_PLAN for possible warning/error IDs.
%  * Full documentation is given in ../finufft-manual.pdf and online at
%    http://finufft.readthedocs.io

function c = finufft1d2(x,isign,eps,f,o)

if nargin<5, o.dummy=1; end
valid_setpts(2,1,x,[],[]);
[ms,n_transf]=size(f);                     % if f a col vec, n_transf=1, but...
if ms==1, ms=n_transf; n_transf=1; end     % allow a single row vec as valid f
p = finufft_plan(2,ms,isign,n_transf,eps,o);
p.finufft_setpts(x,[],[]);
c = p.finufft_exec(f);
delete(p);
