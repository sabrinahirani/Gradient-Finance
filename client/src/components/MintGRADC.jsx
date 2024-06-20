import React, { useState } from 'react';
import { Box, Text, HStack, VStack, Input, Button, extendTheme, ThemeProvider } from '@chakra-ui/react';
import Back from './Back';

// Define a custom theme with teal color scheme for inputs
const customTheme = extendTheme({
  components: {
    Input: {
      variants: {
        flushed: {
          field: {
            bg: 'transparent',
            borderColor: 'teal.500', // Teal border color
            borderBottomWidth: '1px', // Initial bottom border thickness
            _hover: {
              borderColor: 'teal.600', // Darker teal on hover
            },
            _focus: {
              borderColor: 'teal.600', // Darker teal on focus
              boxShadow: 'none',
              borderBottomWidth: '2px', // Thicker bottom border on focus
            },
          },
        },
      },
    },
  },
});

function MintGRADC() {
  const [daiAmount, setDaiAmount] = useState('');
  const [gradcAmount, setGRADCAmount] = useState('');
  const [focusedInput, setFocusedInput] = useState(null);

  const handleInputChange = (value, setter, counterpartSetter) => {
    setter(value);
    counterpartSetter(value);
  };

  const handleSwap = () => {
    const temp = daiAmount;
    setDaiAmount(gradcAmount);
    setGRADCAmount(temp);
  };

  const handleInputFocus = (input) => {
    setFocusedInput(input);
  };

  return (
    <ThemeProvider theme={customTheme}>
      <Box className='mint-gradc' maxWidth='600px' width='100%' mx='auto' p={4}>
        <Back />
        <HStack spacing={4} paddingBottom='16px' width='100%'>
          <VStack align='flex-start' p={2} width='100%'>
            <Text fontSize='sm' color='gray.500'>DAI</Text>
            <Input
              value={daiAmount}
              onChange={(e) => handleInputChange(e.target.value, setDaiAmount, setGRADCAmount)}
              onFocus={() => handleInputFocus('dai')}
              onBlur={() => setFocusedInput(null)}
              variant='flushed'
              pt={10}
              pb={5}
              width='100%'
            />
          </VStack>
          <VStack align='flex-start' p={2} width='100%'>
            <Text fontSize='sm' color='gray.500'>GRADC</Text>
            <Input
              value={gradcAmount}
              onChange={(e) => handleInputChange(e.target.value, setGRADCAmount, setDaiAmount)}
              onFocus={() => handleInputFocus('gradc')}
              onBlur={() => setFocusedInput(null)}
              variant='flushed'
              pt={10}
              pb={5}
              width='100%'
            />
          </VStack>
        </HStack>
        <Button
          colorScheme='teal'
          variant='outline'
          size='md'
          onClick={handleSwap}
          marginTop='16px'
          width='100%'
        >
          Mint GRADC
        </Button>
      </Box>
    </ThemeProvider>
  );
}

export default MintGRADC;
