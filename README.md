# stereocorrespondence
This repo uses stereo vision to provide a dense range (depth) and appearance information. Given an image pair, the functions will produce a disparity map. 

## Files
`stereo_disparity_fast.m` implements a fast local correspondence algorithm. It uses a fixed window size matching routine and sum-of-absolute-difference (SAD) similarity measure. Correct matches are identified using 'winner-takes-all' strategy. <br/>
`stereo_disparity_best.m` implements an alternative matching algorithm based on personal research. Instead of SAD, it uses a rank test to compute the matching cost. Furthermore, it applies a median filter to smooth the result.
