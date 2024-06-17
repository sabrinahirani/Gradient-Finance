import React from 'react';
import { Box, HStack, Heading, Button } from '@chakra-ui/react';
import {ReactTyped} from 'react-typed';
import logo from '../assets/greg-outline.png';

function Home() {
  return (
    <Box className='home'>
      <HStack className='heading'>
        <Heading size='xl'>Gradient Finance</Heading>
        <img className='logo' src={logo} alt="Greg" />
      </HStack>
      <Heading size='sm' color='gradient.500'>
        DeFi meets{' '}
        <ReactTyped
          strings={['AAPL', 'NVDA', 'MSFT', 'AMZN', 'TSLA', 'NFLX']}
          typeSpeed={40}
          backSpeed={50}
          loop
        />
      </Heading>
      <HStack spacing={4} marginTop={8}>
        <Button size='sm' colorScheme='teal' variant='outline'>Mint GRADC</Button>
        <Button size='sm' colorScheme='teal' variant='outline'>Mint Synthetic Asset</Button>
        <Button size='sm' colorScheme='teal' variant='outline'>Trade Synthetic Asset</Button>
        <Button size='sm' colorScheme='teal' variant='outline'>Derivatives</Button>
      </HStack>
    </Box>
  );
}

export default Home;
