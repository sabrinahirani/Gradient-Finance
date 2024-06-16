import React from 'react';
import { Box, HStack, Heading, Button } from '@chakra-ui/react';
import logo from '../assets/greg-outline.png';

function Home() {
  return (
    <Box className='home'>
      <HStack className='heading'>
        <Heading size='xl'>Gradient Finance</Heading>
        <img className='logo' src={logo} alt="Greg" />
      </HStack>
      <Heading size='md'>DeFi meets AAPL</Heading>
      <HStack spacing={4} marginTop={4}>
        <Button>Mint GRADC</Button>
        <Button>Mint Synthetic Asset</Button>
        <Button>Trade Synthetic Asset</Button>
        <Button>Derivatives</Button>
      </HStack>
    </Box>
  );
}

export default Home;
