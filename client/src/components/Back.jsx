import React from 'react';
import { Link } from 'react-router-dom';
import { IconButton } from '@chakra-ui/react';
import { ArrowBackIcon } from '@chakra-ui/icons';

const Back = () => {
  return (
    <Link to="/">
      <IconButton
        icon={<ArrowBackIcon />}
        position="absolute"
        top="20px"
        left="20px"
        color="teal.500"
        zIndex="docked"
      />
    </Link>
  );
};

export default Back;
