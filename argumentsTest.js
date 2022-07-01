module.exports = [
	"0xcDA8eD22bB27Fe84615f368D09B5A8Afe4a99320", // tokenContract
  "0x78867bbeef44f2326bf8ddd1941a4439382ef2a7", // busdAddress
  "0xf47644E079303263a2DE0829895d000900d2fAb8", // pair Narfex -> BUSD in PancakeSwap
  Number(1 * (10**18)).toFixed(0), // min
  Number(5 * (10**18)).toFixed(0), // max
  60 * 10, // First unlock in seconds
  60 * 30, // Percentage unlock in seconds
  Number(0.4 * (10**18)).toFixed(0), // First Narfex Price
];