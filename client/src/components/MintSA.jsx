import React, { useState } from 'react';
import { Box, Text, VStack, HStack, Input, Button, extendTheme, ThemeProvider, Heading } from '@chakra-ui/react';
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
            _hover: {
              borderColor: 'teal.600', // Darker teal on hover
            },
            _focus: {
              borderColor: 'teal.600', // Darker teal on focus
              boxShadow: 'none',
              borderBottomWidth: '2px', // Thicker border on focus
            },
          },
        },
      },
    },
  },
});

function MintSA() {
  const [assetName, setAssetName] = useState('');
  const [ticker, setTicker] = useState('');
  const [valueUSD, setValueUSD] = useState('');
  const [inputs, setInputs] = useState([{ ticker: '', weight: '' }]);

  const handleInputChange = (index, field, value) => {
    const newInputs = inputs.slice();
    newInputs[index][field] = value;
    setInputs(newInputs);
  };

  const addInputField = () => {
    if (inputs.length < 5) {
      setInputs([...inputs, { ticker: '', weight: '' }]);
    }
  };

  const removeInputField = (index) => {
    if (inputs.length > 1) {
      const newInputs = inputs.slice();
      newInputs.splice(index, 1);
      setInputs(newInputs);
    }
  };

  const validateWeights = () => {
    const totalWeight = inputs.reduce((sum, input) => sum + Number(input.weight), 0);
    return totalWeight === 100;
  };

  return (
    <ThemeProvider theme={customTheme}>
      <Box className='create-synthetic-asset' maxWidth='600px' width='100%' mx='auto' p={4}>
        <Back />
        <Heading as='h2' size='lg' mb={4}>Create New Synthetic Asset</Heading>
        <VStack spacing={4} width='100%'>
          <HStack width='100%'>
            <Input
              placeholder='Asset Name'
              value={assetName}
              onChange={(e) => setAssetName(e.target.value)}
              variant='flushed'
              width='70%'
            />
            <Input
              placeholder='Ticker'
              value={ticker}
              onChange={(e) => setTicker(e.target.value)}
              variant='flushed'
              width='30%'
            />
          </HStack>
          <Input
            placeholder='Value in USD'
            value={valueUSD}
            onChange={(e) => setValueUSD(e.target.value)}
            type='number'
            variant='flushed'
            width='100%'
          />
          <Text fontSize='sm' color='gray.500'>Portfolio Composition</Text>
          {inputs.map((input, index) => (
            <HStack key={index} width='100%'>
              <Input
                placeholder='Ticker'
                value={input.ticker}
                onChange={(e) => handleInputChange(index, 'ticker', e.target.value)}
                variant='flushed'
                width='70%'
              />
              <Input
                placeholder='Weight (%)'
                value={input.weight}
                onChange={(e) => handleInputChange(index, 'weight', e.target.value)}
                type='number'
                variant='flushed'
                width='30%'
              />
              {inputs.length > 1 && (
                <Button colorScheme='red' size='sm' onClick={() => removeInputField(index)}>Remove</Button>
              )}
            </HStack>
          ))}
          <Button
            colorScheme='teal'
            onClick={addInputField}
            disabled={inputs.length >= 5}
          >
            Add Field
          </Button>
          <Button
            colorScheme='teal'
            variant='outline'
            size='md'
            marginTop='16px'
            width='100%'
            onClick={() => alert(validateWeights() ? 'Valid weights' : 'Weights must sum to 100')}
          >
            Create Asset
          </Button>
        </VStack>
      </Box>
    </ThemeProvider>
  );
}

export default MintSA;
